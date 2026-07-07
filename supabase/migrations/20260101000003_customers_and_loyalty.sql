-- =============================================================================
-- LoyalFlow — 03. Customers, loyalty programs, cards, points, levels, badges
-- =============================================================================

create type public.loyalty_program_type as enum ('points', 'stamps', 'vip', 'tiers', 'cashback', 'custom');
create type public.loyalty_card_status as enum ('active', 'expired', 'suspended');
create type public.point_transaction_type as enum ('earn', 'redeem', 'adjustment', 'expire', 'referral_bonus', 'birthday_bonus');

-- ---------------------------------------------------------------------------
-- customers (a business's end customer — may or may not have a platform account)
-- ---------------------------------------------------------------------------

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  profile_id uuid references public.profiles (id) on delete set null,
  first_name text not null,
  last_name text,
  email text,
  phone text,
  date_of_birth date,
  avatar_url text,
  notes text,
  is_active boolean not null default true,
  joined_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.customers is 'An end customer of a business (the person holding loyalty cards).';

create index customers_business_id_idx on public.customers (business_id);
create index customers_profile_id_idx on public.customers (profile_id);
create unique index customers_business_profile_unique on public.customers (business_id, profile_id) where profile_id is not null;
create unique index customers_business_email_unique on public.customers (business_id, email) where email is not null;

create trigger set_updated_at
  before update on public.customers
  for each row execute function public.set_updated_at();

-- Now that `customers` exists, define the "is this row mine" helper used
-- throughout RLS policies for customer-scoped tables.
create or replace function public.is_own_customer(target_customer_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.customers c
    where c.id = target_customer_id and c.profile_id = auth.uid()
  );
$$;

comment on function public.is_own_customer(uuid) is 'True if the given customers row belongs to the current auth user.';

create or replace function public.is_customer_of_business(target_business_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.customers c
    where c.business_id = target_business_id and c.profile_id = auth.uid()
  );
$$;

comment on function public.is_customer_of_business(uuid) is
  'True if the current auth user is a registered customer of the given business (used to let customers read the public-facing info of businesses they hold a card with, without granting anonymous/guest access).';

-- ---------------------------------------------------------------------------
-- loyalty_programs
-- ---------------------------------------------------------------------------

create table public.loyalty_programs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  name text not null,
  description text,
  type public.loyalty_program_type not null default 'points',
  icon text,
  color text not null default '#4F46E5',
  rules jsonb not null default '{}'::jsonb,
  points_per_visit numeric(10, 2),
  points_per_currency numeric(10, 2),
  stamps_required integer,
  expiry_days integer,
  is_active boolean not null default true,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint loyalty_programs_stamps_required_positive check (stamps_required is null or stamps_required > 0)
);

comment on table public.loyalty_programs is 'A loyalty program definition owned by a business (points, stamps, VIP, tiers, cashback...).';

create index loyalty_programs_business_id_idx on public.loyalty_programs (business_id);

create trigger set_updated_at
  before update on public.loyalty_programs
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- loyalty_cards (a customer's membership in a loyalty program)
-- ---------------------------------------------------------------------------

create table public.loyalty_cards (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  loyalty_program_id uuid not null references public.loyalty_programs (id) on delete cascade,
  card_number text not null unique,
  current_points numeric(12, 2) not null default 0,
  current_stamps integer not null default 0,
  tier text,
  status public.loyalty_card_status not null default 'active',
  issued_at timestamptz not null default now(),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (customer_id, loyalty_program_id)
);

comment on table public.loyalty_cards is 'A digital loyalty card: one customer enrolled in one loyalty program.';

create index loyalty_cards_business_id_idx on public.loyalty_cards (business_id);
create index loyalty_cards_customer_id_idx on public.loyalty_cards (customer_id);
create index loyalty_cards_program_id_idx on public.loyalty_cards (loyalty_program_id);

create trigger set_updated_at
  before update on public.loyalty_cards
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- loyalty_points (current balance head, one row per card)
-- ---------------------------------------------------------------------------

create table public.loyalty_points (
  id uuid primary key default gen_random_uuid(),
  loyalty_card_id uuid not null unique references public.loyalty_cards (id) on delete cascade,
  balance numeric(12, 2) not null default 0,
  lifetime_earned numeric(12, 2) not null default 0,
  lifetime_redeemed numeric(12, 2) not null default 0,
  last_transaction_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.loyalty_points is 'Current point balance per loyalty card (head of the point_transactions ledger).';

create trigger set_updated_at
  before update on public.loyalty_points
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_loyalty_card()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.loyalty_points (loyalty_card_id) values (new.id);
  return new;
end;
$$;

create trigger on_loyalty_card_created
  after insert on public.loyalty_cards
  for each row execute function public.handle_new_loyalty_card();

-- ---------------------------------------------------------------------------
-- point_transactions (ledger)
-- ---------------------------------------------------------------------------

create table public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  loyalty_card_id uuid not null references public.loyalty_cards (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  type public.point_transaction_type not null,
  points numeric(12, 2) not null,
  balance_after numeric(12, 2) not null,
  reference_type text,
  reference_id uuid,
  note text,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

comment on table public.point_transactions is 'Append-only ledger of every point movement (earn/redeem/adjustment/expire).';

create index point_transactions_card_id_idx on public.point_transactions (loyalty_card_id);
create index point_transactions_customer_id_idx on public.point_transactions (customer_id);
create index point_transactions_business_id_idx on public.point_transactions (business_id);
create index point_transactions_created_at_idx on public.point_transactions (created_at);

-- Keep loyalty_points/loyalty_cards balances in sync with the ledger.
create or replace function public.apply_point_transaction()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.loyalty_points
  set
    balance = new.balance_after,
    lifetime_earned = lifetime_earned + greatest(new.points, 0),
    lifetime_redeemed = lifetime_redeemed + greatest(-new.points, 0),
    last_transaction_at = new.created_at
  where loyalty_card_id = new.loyalty_card_id;

  update public.loyalty_cards
  set current_points = new.balance_after
  where id = new.loyalty_card_id;

  return new;
end;
$$;

create trigger on_point_transaction_created
  after insert on public.point_transactions
  for each row execute function public.apply_point_transaction();

-- ---------------------------------------------------------------------------
-- customer_levels (Bronze/Silver/Gold/Platinum tiers, per business)
-- ---------------------------------------------------------------------------

create table public.customer_levels (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  name text not null,
  min_points numeric(12, 2) not null default 0,
  color text not null default '#94A3B8',
  icon text,
  benefits jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, name)
);

comment on table public.customer_levels is 'Membership tier definitions (Bronze/Silver/Gold/Platinum) per business.';

create index customer_levels_business_id_idx on public.customer_levels (business_id);

create trigger set_updated_at
  before update on public.customer_levels
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- customer_badges (gamification achievements)
-- ---------------------------------------------------------------------------

create table public.customer_badges (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  badge_key text not null,
  name text not null,
  description text,
  icon text,
  earned_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (customer_id, badge_key)
);

comment on table public.customer_badges is 'Achievement badges earned by a customer (first visit, streaks, VIP, ...).';

create index customer_badges_business_id_idx on public.customer_badges (business_id);
create index customer_badges_customer_id_idx on public.customer_badges (customer_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.customers enable row level security;
alter table public.loyalty_programs enable row level security;
alter table public.loyalty_cards enable row level security;
alter table public.loyalty_points enable row level security;
alter table public.point_transactions enable row level security;
alter table public.customer_levels enable row level security;
alter table public.customer_badges enable row level security;

-- customers
create policy "customers_select_member_or_self" on public.customers
  for select using (
    public.is_business_member(business_id) or profile_id = auth.uid() or public.is_super_admin()
  );

create policy "customers_insert_member" on public.customers
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

create policy "customers_update_member" on public.customers
  for update using (public.is_business_member(business_id) or public.is_super_admin());

create policy "customers_delete_manager" on public.customers
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- businesses / business_locations: additive policies granting read access to a
-- business's own customers (defined here since is_customer_of_business needs
-- the customers table). Combined with the policies from migration 02 via OR.
create policy "businesses_select_customer" on public.businesses
  for select using (public.is_customer_of_business(id));

create policy "business_locations_select_customer" on public.business_locations
  for select using (public.is_customer_of_business(business_id));

-- loyalty_programs: members and the business's own customers can read; managers write.
create policy "loyalty_programs_select_member_or_customer" on public.loyalty_programs
  for select using (
    public.is_business_member(business_id)
    or public.is_customer_of_business(business_id)
    or public.is_super_admin()
  );

create policy "loyalty_programs_insert_manager" on public.loyalty_programs
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "loyalty_programs_update_manager" on public.loyalty_programs
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "loyalty_programs_delete_manager" on public.loyalty_programs
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- loyalty_cards: business members + the owning customer.
create policy "loyalty_cards_select_member_or_self" on public.loyalty_cards
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "loyalty_cards_insert_member" on public.loyalty_cards
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

create policy "loyalty_cards_update_member" on public.loyalty_cards
  for update using (public.is_business_member(business_id) or public.is_super_admin());

create policy "loyalty_cards_delete_manager" on public.loyalty_cards
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- loyalty_points: read-only via card ownership; writes only via trigger (service role bypasses RLS).
create policy "loyalty_points_select_member_or_self" on public.loyalty_points
  for select using (
    public.is_super_admin()
    or exists (
      select 1 from public.loyalty_cards lc
      where lc.id = loyalty_points.loyalty_card_id
        and (public.is_business_member(lc.business_id) or public.is_own_customer(lc.customer_id))
    )
  );

-- point_transactions: members can insert (earn/redeem via app), everyone in scope can read.
create policy "point_transactions_select_member_or_self" on public.point_transactions
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "point_transactions_insert_member" on public.point_transactions
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

-- customer_levels: members and the business's own customers can read; managers write.
create policy "customer_levels_select_member_or_customer" on public.customer_levels
  for select using (
    public.is_business_member(business_id)
    or public.is_customer_of_business(business_id)
    or public.is_super_admin()
  );

create policy "customer_levels_insert_manager" on public.customer_levels
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "customer_levels_update_manager" on public.customer_levels
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "customer_levels_delete_manager" on public.customer_levels
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- customer_badges: members + the owning customer can read; members can grant.
create policy "customer_badges_select_member_or_self" on public.customer_badges
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "customer_badges_insert_member" on public.customer_badges
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

create policy "customer_badges_delete_manager" on public.customer_badges
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());
