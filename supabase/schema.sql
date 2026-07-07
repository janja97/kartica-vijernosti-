-- =============================================================================
-- LoyalFlow — 01. Extensions & generic helper functions
-- =============================================================================

create extension if not exists "pgcrypto" with schema public;

-- Generic trigger function: keeps `updated_at` in sync on every UPDATE.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'Sets updated_at = now() on row update. Attached as a BEFORE UPDATE trigger to every table that has an updated_at column.';

-- =============================================================================
-- LoyalFlow — 02. Core identity: profiles, businesses, membership, locations, settings
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.user_role as enum ('user', 'super_admin');

create type public.business_member_role as enum ('owner', 'admin', 'employee');

create type public.business_category as enum (
  'restaurant', 'cafe', 'hair_salon', 'beauty_salon', 'fitness', 'gym',
  'car_wash', 'auto_service', 'retail', 'bakery', 'patisserie', 'hotel',
  'apartment', 'dental', 'veterinary', 'other'
);

-- ---------------------------------------------------------------------------
-- profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  first_name text,
  last_name text,
  phone text,
  avatar_url text,
  date_of_birth date,
  role public.user_role not null default 'user',
  locale text not null default 'hr',
  timezone text not null default 'Europe/Zagreb',
  is_active boolean not null default true,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is 'One row per auth.users account; holds profile data and the system-level role.';

create index profiles_role_idx on public.profiles (role);

create trigger set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, first_name, last_name)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- businesses (tenant entity)
-- ---------------------------------------------------------------------------

create table public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete restrict,
  name text not null,
  slug text not null unique,
  category public.business_category not null default 'other',
  description text,
  logo_url text,
  cover_image_url text,
  email text,
  phone text,
  website text,
  address_line text,
  city text,
  country text not null default 'HR',
  postal_code text,
  currency text not null default 'EUR',
  timezone text not null default 'Europe/Zagreb',
  is_active boolean not null default true,
  onboarding_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint businesses_slug_format check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);

comment on table public.businesses is 'A tenant on the platform (restaurant, salon, gym, etc.).';

create index businesses_owner_id_idx on public.businesses (owner_id);
create index businesses_category_idx on public.businesses (category);

create trigger set_updated_at
  before update on public.businesses
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- business_members (pivot: profiles <-> businesses)
-- ---------------------------------------------------------------------------

create table public.business_members (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  profile_id uuid not null references public.profiles (id) on delete cascade,
  role public.business_member_role not null default 'employee',
  invited_by uuid references public.profiles (id) on delete set null,
  is_active boolean not null default true,
  joined_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, profile_id)
);

comment on table public.business_members is 'Membership + role of a profile within a business (owner/admin/employee).';

create index business_members_business_id_idx on public.business_members (business_id);
create index business_members_profile_id_idx on public.business_members (profile_id);

create trigger set_updated_at
  before update on public.business_members
  for each row execute function public.set_updated_at();

-- Automatically make the creator of a business its "owner" member.
create or replace function public.handle_new_business()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.business_members (business_id, profile_id, role, is_active)
  values (new.id, new.owner_id, 'owner', true);
  return new;
end;
$$;

create trigger on_business_created
  after insert on public.businesses
  for each row execute function public.handle_new_business();

-- ---------------------------------------------------------------------------
-- business_locations
-- ---------------------------------------------------------------------------

create table public.business_locations (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  name text not null,
  address_line text,
  city text,
  postal_code text,
  country text not null default 'HR',
  latitude numeric(9, 6),
  longitude numeric(9, 6),
  phone text,
  opening_hours jsonb not null default '{}'::jsonb,
  is_primary boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.business_locations is 'Physical locations/branches belonging to a business.';

create index business_locations_business_id_idx on public.business_locations (business_id);

create trigger set_updated_at
  before update on public.business_locations
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- business_settings (1:1 with businesses)
-- ---------------------------------------------------------------------------

create table public.business_settings (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null unique references public.businesses (id) on delete cascade,
  social_links jsonb not null default '{}'::jsonb,
  notification_preferences jsonb not null default '{}'::jsonb,
  birthday_rewards_enabled boolean not null default true,
  referral_program_enabled boolean not null default true,
  default_points_per_currency numeric(10, 2) not null default 1,
  default_visit_cooldown_minutes integer not null default 60,
  privacy_settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.business_settings is 'Per-business configuration (notifications, birthday/referral toggles, cooldowns).';

create trigger set_updated_at
  before update on public.business_settings
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_business_settings()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.business_settings (business_id)
  values (new.id);
  return new;
end;
$$;

create trigger on_business_created_settings
  after insert on public.businesses
  for each row execute function public.handle_new_business_settings();

-- ---------------------------------------------------------------------------
-- RLS helper functions (used across every migration in this project)
-- ---------------------------------------------------------------------------

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.role = 'super_admin'
  );
$$;

create or replace function public.get_business_role(target_business_id uuid)
returns public.business_member_role
language sql
stable
security definer
set search_path = public
as $$
  select bm.role
  from public.business_members bm
  where bm.business_id = target_business_id
    and bm.profile_id = auth.uid()
    and bm.is_active = true
  limit 1;
$$;

create or replace function public.is_business_member(target_business_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.get_business_role(target_business_id) is not null;
$$;

create or replace function public.is_business_manager(target_business_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.get_business_role(target_business_id) in ('owner', 'admin');
$$;

comment on function public.is_super_admin() is 'True if the current auth user is a platform super admin.';
comment on function public.get_business_role(uuid) is 'Returns the caller''s membership role for a business, or null if not a member.';
comment on function public.is_business_member(uuid) is 'True if the current auth user belongs to the given business (any role).';
comment on function public.is_business_manager(uuid) is 'True if the current auth user is owner/admin of the given business.';

-- Note: is_own_customer(uuid) is created in the next migration, once the
-- `customers` table exists (SQL-language functions are validated at CREATE time).

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.business_locations enable row level security;
alter table public.business_settings enable row level security;

-- profiles: users manage their own profile; business managers can see profiles
-- of people who belong to their business; super admins see everything.
create policy "profiles_select_own_or_related" on public.profiles
  for select using (
    id = auth.uid()
    or public.is_super_admin()
    or exists (
      select 1 from public.business_members bm
      where bm.profile_id = public.profiles.id
        and public.is_business_manager(bm.business_id)
    )
  );

create policy "profiles_update_own" on public.profiles
  for update using (id = auth.uid() or public.is_super_admin());

create policy "profiles_insert_own" on public.profiles
  for insert with check (id = auth.uid() or public.is_super_admin());

create policy "profiles_delete_own" on public.profiles
  for delete using (id = auth.uid() or public.is_super_admin());

-- businesses: only members (and, via an additive policy added once `customers`
-- exists, a business's own customers) can read — no anonymous/guest access.
create policy "businesses_select_member" on public.businesses
  for select using (
    public.is_business_member(id)
    or public.is_super_admin()
  );

create policy "businesses_insert_authenticated" on public.businesses
  for insert with check (owner_id = auth.uid() or public.is_super_admin());

create policy "businesses_update_manager" on public.businesses
  for update using (public.is_business_manager(id) or public.is_super_admin());

create policy "businesses_delete_owner" on public.businesses
  for delete using (owner_id = auth.uid() or public.is_super_admin());

-- business_members: visible/manageable by managers of that business.
create policy "business_members_select_member" on public.business_members
  for select using (
    public.is_business_member(business_id)
    or profile_id = auth.uid()
    or public.is_super_admin()
  );

create policy "business_members_insert_manager" on public.business_members
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "business_members_update_manager" on public.business_members
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "business_members_delete_manager" on public.business_members
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- business_locations: members only (no anonymous/guest access); managers write.
create policy "business_locations_select_member" on public.business_locations
  for select using (
    public.is_business_member(business_id) or public.is_super_admin()
  );

create policy "business_locations_insert_manager" on public.business_locations
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "business_locations_update_manager" on public.business_locations
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "business_locations_delete_manager" on public.business_locations
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- business_settings: only members can see; only managers can write.
create policy "business_settings_select_member" on public.business_settings
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "business_settings_insert_manager" on public.business_settings
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "business_settings_update_manager" on public.business_settings
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "business_settings_delete_manager" on public.business_settings
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

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

-- =============================================================================
-- LoyalFlow — 04. QR codes & customer visits (with anti-abuse cooldown)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- qr_codes (one active QR token per customer per business)
-- ---------------------------------------------------------------------------

create table public.qr_codes (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  code text not null unique,
  is_active boolean not null default true,
  last_scanned_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, customer_id)
);

comment on table public.qr_codes is 'The unique QR token used to identify a customer when scanned at a business.';

create index qr_codes_business_id_idx on public.qr_codes (business_id);
create index qr_codes_customer_id_idx on public.qr_codes (customer_id);

create trigger set_updated_at
  before update on public.qr_codes
  for each row execute function public.set_updated_at();

-- Auto-issue a QR code whenever a customer is created.
create or replace function public.handle_new_customer_qr()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.qr_codes (business_id, customer_id, code)
  values (new.business_id, new.id, replace(gen_random_uuid()::text, '-', ''));
  return new;
end;
$$;

create trigger on_customer_created_qr
  after insert on public.customers
  for each row execute function public.handle_new_customer_qr();

-- ---------------------------------------------------------------------------
-- customer_visits
-- ---------------------------------------------------------------------------

create table public.customer_visits (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  loyalty_card_id uuid references public.loyalty_cards (id) on delete set null,
  business_location_id uuid references public.business_locations (id) on delete set null,
  qr_code_id uuid references public.qr_codes (id) on delete set null,
  points_earned numeric(12, 2) not null default 0,
  stamps_earned integer not null default 0,
  amount_spent numeric(10, 2),
  scanned_by uuid references public.profiles (id) on delete set null,
  visited_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

comment on table public.customer_visits is 'A confirmed QR scan / visit event, optionally tied to a loyalty card.';

create index customer_visits_business_id_idx on public.customer_visits (business_id);
create index customer_visits_customer_id_idx on public.customer_visits (customer_id);
create index customer_visits_customer_visited_at_idx on public.customer_visits (customer_id, visited_at desc);

-- Anti-abuse: reject a new visit if the customer was already scanned for this
-- business within its configured cooldown window (default_visit_cooldown_minutes).
create or replace function public.enforce_visit_cooldown()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  cooldown_minutes integer;
  last_visit_at timestamptz;
begin
  select coalesce(bs.default_visit_cooldown_minutes, 60)
  into cooldown_minutes
  from public.business_settings bs
  where bs.business_id = new.business_id;

  select max(v.visited_at)
  into last_visit_at
  from public.customer_visits v
  where v.business_id = new.business_id
    and v.customer_id = new.customer_id;

  if last_visit_at is not null and new.visited_at < last_visit_at + make_interval(mins => cooldown_minutes) then
    raise exception 'visit_cooldown_active: customer already scanned within the cooldown window'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

create trigger enforce_visit_cooldown_trigger
  before insert on public.customer_visits
  for each row execute function public.enforce_visit_cooldown();

-- Keep qr_codes.last_scanned_at in sync.
create or replace function public.touch_qr_code_last_scanned()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.qr_code_id is not null then
    update public.qr_codes set last_scanned_at = new.visited_at where id = new.qr_code_id;
  end if;
  return new;
end;
$$;

create trigger on_customer_visit_touch_qr
  after insert on public.customer_visits
  for each row execute function public.touch_qr_code_last_scanned();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.qr_codes enable row level security;
alter table public.customer_visits enable row level security;

create policy "qr_codes_select_member_or_self" on public.qr_codes
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "qr_codes_insert_member" on public.qr_codes
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

create policy "qr_codes_update_member" on public.qr_codes
  for update using (public.is_business_member(business_id) or public.is_super_admin());

create policy "customer_visits_select_member_or_self" on public.customer_visits
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

-- Any active business member (including employees) may confirm a visit/scan.
create policy "customer_visits_insert_member" on public.customer_visits
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 05. Reward catalog, redemptions, customer reward wallet
-- =============================================================================

create type public.reward_type as enum ('free_item', 'discount', 'gift', 'cashback', 'coupon', 'vip_perk');
create type public.redemption_status as enum ('pending', 'approved', 'rejected', 'fulfilled');
create type public.customer_reward_source as enum ('redemption', 'birthday', 'referral', 'campaign', 'manual');
create type public.customer_reward_status as enum ('active', 'used', 'expired');

-- ---------------------------------------------------------------------------
-- reward_catalog
-- ---------------------------------------------------------------------------

create table public.reward_catalog (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  loyalty_program_id uuid references public.loyalty_programs (id) on delete cascade,
  name text not null,
  description text,
  image_url text,
  type public.reward_type not null default 'discount',
  points_cost numeric(12, 2),
  stamps_cost integer,
  discount_percent numeric(5, 2),
  cashback_amount numeric(10, 2),
  stock_quantity integer,
  is_active boolean not null default true,
  valid_from timestamptz,
  valid_until timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reward_catalog_stock_non_negative check (stock_quantity is null or stock_quantity >= 0)
);

comment on table public.reward_catalog is 'Rewards a business offers (free item, discount, cashback, coupon, VIP perk...).';

create index reward_catalog_business_id_idx on public.reward_catalog (business_id);
create index reward_catalog_program_id_idx on public.reward_catalog (loyalty_program_id);

create trigger set_updated_at
  before update on public.reward_catalog
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- reward_redemptions (a customer spending points/stamps on a reward)
-- ---------------------------------------------------------------------------

create table public.reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  reward_id uuid not null references public.reward_catalog (id) on delete cascade,
  loyalty_card_id uuid references public.loyalty_cards (id) on delete set null,
  points_spent numeric(12, 2) not null default 0,
  stamps_spent integer not null default 0,
  status public.redemption_status not null default 'pending',
  redeemed_by uuid references public.profiles (id) on delete set null,
  redeemed_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.reward_redemptions is 'A customer request to redeem a reward, confirmed/fulfilled by an employee.';

create index reward_redemptions_business_id_idx on public.reward_redemptions (business_id);
create index reward_redemptions_customer_id_idx on public.reward_redemptions (customer_id);
create index reward_redemptions_reward_id_idx on public.reward_redemptions (reward_id);

create trigger set_updated_at
  before update on public.reward_redemptions
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- customer_rewards (a customer's wallet of unlocked/earned rewards)
-- ---------------------------------------------------------------------------

create table public.customer_rewards (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  reward_id uuid not null references public.reward_catalog (id) on delete cascade,
  source public.customer_reward_source not null default 'redemption',
  status public.customer_reward_status not null default 'active',
  unlocked_at timestamptz not null default now(),
  used_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.customer_rewards is 'Rewards a customer currently holds (earned via redemption, birthday, referral or campaign).';

create index customer_rewards_business_id_idx on public.customer_rewards (business_id);
create index customer_rewards_customer_id_idx on public.customer_rewards (customer_id);

create trigger set_updated_at
  before update on public.customer_rewards
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.reward_catalog enable row level security;
alter table public.reward_redemptions enable row level security;
alter table public.customer_rewards enable row level security;

-- reward_catalog: members and the business's own customers can read; managers write.
create policy "reward_catalog_select_member_or_customer" on public.reward_catalog
  for select using (
    public.is_business_member(business_id)
    or public.is_customer_of_business(business_id)
    or public.is_super_admin()
  );

create policy "reward_catalog_insert_manager" on public.reward_catalog
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "reward_catalog_update_manager" on public.reward_catalog
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "reward_catalog_delete_manager" on public.reward_catalog
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- reward_redemptions: customer creates the request, member/employee confirms it.
create policy "reward_redemptions_select_member_or_self" on public.reward_redemptions
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "reward_redemptions_insert_member_or_self" on public.reward_redemptions
  for insert with check (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "reward_redemptions_update_member" on public.reward_redemptions
  for update using (public.is_business_member(business_id) or public.is_super_admin());

-- customer_rewards: members manage, customer can read their own wallet.
create policy "customer_rewards_select_member_or_self" on public.customer_rewards
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "customer_rewards_insert_member" on public.customer_rewards
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

create policy "customer_rewards_update_member" on public.customer_rewards
  for update using (public.is_business_member(business_id) or public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 06. Marketing: campaigns, promo codes, birthday rewards, referrals
-- =============================================================================

create type public.campaign_channel as enum ('email', 'push', 'sms', 'in_app');
create type public.campaign_status as enum ('draft', 'scheduled', 'active', 'completed', 'archived');
create type public.campaign_recipient_status as enum ('pending', 'sent', 'delivered', 'failed', 'opened', 'clicked');
create type public.birthday_reward_type as enum ('discount', 'free_item', 'free_service', 'gift', 'points_bonus', 'none');
create type public.referral_status as enum ('pending', 'completed', 'expired');
create type public.referral_reward_role as enum ('referrer', 'referred');
create type public.referral_reward_type as enum ('points', 'stamps', 'discount', 'free_item');

-- ---------------------------------------------------------------------------
-- campaigns
-- ---------------------------------------------------------------------------

create table public.campaigns (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  name text not null,
  description text,
  channel public.campaign_channel not null default 'email',
  status public.campaign_status not null default 'draft',
  content jsonb not null default '{}'::jsonb,
  image_url text,
  target_segment jsonb not null default '{}'::jsonb,
  scheduled_at timestamptz,
  sent_at timestamptz,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.campaigns is 'A marketing campaign (email/push/sms/in-app) targeting a customer segment.';

create index campaigns_business_id_idx on public.campaigns (business_id);
create index campaigns_status_idx on public.campaigns (status);

create trigger set_updated_at
  before update on public.campaigns
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- campaign_recipients
-- ---------------------------------------------------------------------------

create table public.campaign_recipients (
  id uuid primary key default gen_random_uuid(),
  campaign_id uuid not null references public.campaigns (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  status public.campaign_recipient_status not null default 'pending',
  sent_at timestamptz,
  opened_at timestamptz,
  error_message text,
  created_at timestamptz not null default now(),
  unique (campaign_id, customer_id)
);

comment on table public.campaign_recipients is 'Per-customer delivery status for a campaign.';

create index campaign_recipients_campaign_id_idx on public.campaign_recipients (campaign_id);
create index campaign_recipients_customer_id_idx on public.campaign_recipients (customer_id);

-- ---------------------------------------------------------------------------
-- promo_codes
-- ---------------------------------------------------------------------------

create table public.promo_codes (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  code text not null,
  description text,
  discount_percent numeric(5, 2),
  discount_amount numeric(10, 2),
  max_redemptions integer,
  times_redeemed integer not null default 0,
  is_active boolean not null default true,
  starts_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, code),
  constraint promo_codes_redemptions_non_negative check (times_redeemed >= 0)
);

comment on table public.promo_codes is 'Discount/promo codes issued by a business.';

create index promo_codes_business_id_idx on public.promo_codes (business_id);

create trigger set_updated_at
  before update on public.promo_codes
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- birthday_rewards (per-business config, singleton per business)
-- ---------------------------------------------------------------------------

create table public.birthday_rewards (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null unique references public.businesses (id) on delete cascade,
  is_enabled boolean not null default true,
  reward_type public.birthday_reward_type not null default 'discount',
  reward_value jsonb not null default '{}'::jsonb,
  days_before integer not null default 0,
  valid_days integer not null default 7,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.birthday_rewards is 'Birthday perk configuration for a business (discount/free item/gift/points/none).';

create trigger set_updated_at
  before update on public.birthday_rewards
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- referrals & referral_rewards
-- ---------------------------------------------------------------------------

create table public.referrals (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  referrer_customer_id uuid not null references public.customers (id) on delete cascade,
  referred_customer_id uuid references public.customers (id) on delete cascade,
  referred_email text,
  referral_code text not null unique,
  status public.referral_status not null default 'pending',
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.referrals is 'A "refer a friend" invitation issued by a customer.';

create index referrals_business_id_idx on public.referrals (business_id);
create index referrals_referrer_idx on public.referrals (referrer_customer_id);

create trigger set_updated_at
  before update on public.referrals
  for each row execute function public.set_updated_at();

create table public.referral_rewards (
  id uuid primary key default gen_random_uuid(),
  referral_id uuid not null references public.referrals (id) on delete cascade,
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  role public.referral_reward_role not null,
  reward_type public.referral_reward_type not null default 'points',
  reward_value jsonb not null default '{}'::jsonb,
  granted_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

comment on table public.referral_rewards is 'The concrete reward granted to referrer/referred once a referral completes.';

create index referral_rewards_referral_id_idx on public.referral_rewards (referral_id);
create index referral_rewards_customer_id_idx on public.referral_rewards (customer_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.campaigns enable row level security;
alter table public.campaign_recipients enable row level security;
alter table public.promo_codes enable row level security;
alter table public.birthday_rewards enable row level security;
alter table public.referrals enable row level security;
alter table public.referral_rewards enable row level security;

create policy "campaigns_select_member" on public.campaigns
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "campaigns_insert_manager" on public.campaigns
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "campaigns_update_manager" on public.campaigns
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "campaigns_delete_manager" on public.campaigns
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "campaign_recipients_select_member_or_self" on public.campaign_recipients
  for select using (
    public.is_super_admin()
    or exists (
      select 1 from public.campaigns c
      where c.id = campaign_recipients.campaign_id and public.is_business_member(c.business_id)
    )
    or public.is_own_customer(customer_id)
  );

create policy "campaign_recipients_insert_manager" on public.campaign_recipients
  for insert with check (
    public.is_super_admin()
    or exists (
      select 1 from public.campaigns c
      where c.id = campaign_recipients.campaign_id and public.is_business_manager(c.business_id)
    )
  );

create policy "promo_codes_select_member_or_customer" on public.promo_codes
  for select using (
    public.is_business_member(business_id)
    or public.is_customer_of_business(business_id)
    or public.is_super_admin()
  );

create policy "promo_codes_insert_manager" on public.promo_codes
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "promo_codes_update_manager" on public.promo_codes
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "promo_codes_delete_manager" on public.promo_codes
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "birthday_rewards_select_member" on public.birthday_rewards
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "birthday_rewards_insert_manager" on public.birthday_rewards
  for insert with check (public.is_business_manager(business_id) or public.is_super_admin());

create policy "birthday_rewards_update_manager" on public.birthday_rewards
  for update using (public.is_business_manager(business_id) or public.is_super_admin());

create policy "referrals_select_member_or_self" on public.referrals
  for select using (
    public.is_business_member(business_id)
    or public.is_own_customer(referrer_customer_id)
    or public.is_own_customer(referred_customer_id)
    or public.is_super_admin()
  );

create policy "referrals_insert_member_or_self" on public.referrals
  for insert with check (
    public.is_business_member(business_id) or public.is_own_customer(referrer_customer_id) or public.is_super_admin()
  );

create policy "referrals_update_member" on public.referrals
  for update using (public.is_business_member(business_id) or public.is_super_admin());

create policy "referral_rewards_select_member_or_self" on public.referral_rewards
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "referral_rewards_insert_member" on public.referral_rewards
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 07. Engagement: favorites, reviews, feedback, appointments
-- =============================================================================

create type public.feedback_category as enum ('general', 'bug', 'feature_request', 'complaint', 'compliment');
create type public.feedback_status as enum ('open', 'reviewed', 'resolved');
create type public.appointment_status as enum ('pending', 'confirmed', 'completed', 'cancelled', 'no_show');

-- ---------------------------------------------------------------------------
-- favorites (a platform user favoriting a business)
-- ---------------------------------------------------------------------------

create table public.favorites (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  business_id uuid not null references public.businesses (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (profile_id, business_id)
);

comment on table public.favorites is 'Businesses a platform user has marked as favorite.';

create index favorites_profile_id_idx on public.favorites (profile_id);
create index favorites_business_id_idx on public.favorites (business_id);

-- ---------------------------------------------------------------------------
-- reviews
-- ---------------------------------------------------------------------------

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  rating integer not null,
  comment text,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, customer_id),
  constraint reviews_rating_range check (rating between 1 and 5)
);

comment on table public.reviews is 'A customer review/rating of a business.';

create index reviews_business_id_idx on public.reviews (business_id);

create trigger set_updated_at
  before update on public.reviews
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- feedback (platform or business-directed feedback)
-- ---------------------------------------------------------------------------

create table public.feedback (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete cascade,
  profile_id uuid references public.profiles (id) on delete set null,
  category public.feedback_category not null default 'general',
  message text not null,
  status public.feedback_status not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.feedback is 'Free-form feedback from a user, optionally directed at a specific business.';

create index feedback_business_id_idx on public.feedback (business_id);
create index feedback_profile_id_idx on public.feedback (profile_id);

create trigger set_updated_at
  before update on public.feedback
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- appointments (za buduću upotrebu — booking modul)
-- ---------------------------------------------------------------------------

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  customer_id uuid not null references public.customers (id) on delete cascade,
  business_location_id uuid references public.business_locations (id) on delete set null,
  service_name text,
  status public.appointment_status not null default 'pending',
  scheduled_at timestamptz not null,
  duration_minutes integer not null default 30,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint appointments_duration_positive check (duration_minutes > 0)
);

comment on table public.appointments is 'Reserved for the future booking/appointments module.';

create index appointments_business_id_idx on public.appointments (business_id);
create index appointments_customer_id_idx on public.appointments (customer_id);
create index appointments_scheduled_at_idx on public.appointments (scheduled_at);

create trigger set_updated_at
  before update on public.appointments
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.favorites enable row level security;
alter table public.reviews enable row level security;
alter table public.feedback enable row level security;
alter table public.appointments enable row level security;

create policy "favorites_select_own" on public.favorites
  for select using (profile_id = auth.uid() or public.is_super_admin());

create policy "favorites_insert_own" on public.favorites
  for insert with check (profile_id = auth.uid() or public.is_super_admin());

create policy "favorites_delete_own" on public.favorites
  for delete using (profile_id = auth.uid() or public.is_super_admin());

create policy "reviews_select_published_or_member" on public.reviews
  for select using (
    is_published = true or public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "reviews_insert_self" on public.reviews
  for insert with check (public.is_own_customer(customer_id) or public.is_super_admin());

create policy "reviews_update_self_or_manager" on public.reviews
  for update using (
    public.is_own_customer(customer_id) or public.is_business_manager(business_id) or public.is_super_admin()
  );

create policy "reviews_delete_self_or_manager" on public.reviews
  for delete using (
    public.is_own_customer(customer_id) or public.is_business_manager(business_id) or public.is_super_admin()
  );

create policy "feedback_select_own_or_member" on public.feedback
  for select using (
    profile_id = auth.uid()
    or public.is_super_admin()
    or (business_id is not null and public.is_business_manager(business_id))
  );

create policy "feedback_insert_own" on public.feedback
  for insert with check (profile_id = auth.uid() or public.is_super_admin());

create policy "feedback_update_manager" on public.feedback
  for update using (
    public.is_super_admin() or (business_id is not null and public.is_business_manager(business_id))
  );

create policy "appointments_select_member_or_self" on public.appointments
  for select using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "appointments_insert_member_or_self" on public.appointments
  for insert with check (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "appointments_update_member_or_self" on public.appointments
  for update using (
    public.is_business_member(business_id) or public.is_own_customer(customer_id) or public.is_super_admin()
  );

create policy "appointments_delete_manager" on public.appointments
  for delete using (public.is_business_manager(business_id) or public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 08. Notifications, email templates/logs, device tokens
-- =============================================================================

create type public.notification_type as enum ('info', 'success', 'warning', 'reward', 'points', 'visit', 'system');
create type public.notification_channel as enum ('email', 'push', 'sms', 'in_app');
create type public.delivery_status as enum ('queued', 'sent', 'delivered', 'failed', 'bounced');
create type public.device_platform as enum ('web', 'ios', 'android');

-- ---------------------------------------------------------------------------
-- notifications (in-app)
-- ---------------------------------------------------------------------------

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete cascade,
  recipient_profile_id uuid not null references public.profiles (id) on delete cascade,
  type public.notification_type not null default 'info',
  title text not null,
  body text,
  data jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

comment on table public.notifications is 'In-app notifications shown in the recipient''s notification center.';

create index notifications_recipient_idx on public.notifications (recipient_profile_id, is_read);
create index notifications_business_id_idx on public.notifications (business_id);

-- ---------------------------------------------------------------------------
-- notification_logs (delivery log for push/sms/in-app sends triggered by automations/campaigns)
-- ---------------------------------------------------------------------------

create table public.notification_logs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete cascade,
  customer_id uuid references public.customers (id) on delete cascade,
  channel public.notification_channel not null default 'push',
  template_key text,
  payload jsonb not null default '{}'::jsonb,
  status public.delivery_status not null default 'queued',
  error_message text,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

comment on table public.notification_logs is 'Delivery log for automated notifications (birthday, campaigns, reminders...).';

create index notification_logs_business_id_idx on public.notification_logs (business_id);
create index notification_logs_customer_id_idx on public.notification_logs (customer_id);

-- ---------------------------------------------------------------------------
-- email_templates
-- ---------------------------------------------------------------------------

create table public.email_templates (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete cascade,
  key text not null,
  name text not null,
  subject text not null,
  body_html text not null,
  variables jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, key)
);

comment on table public.email_templates is 'Reusable email templates. business_id = null means a shared system template.';

create index email_templates_business_id_idx on public.email_templates (business_id);

create trigger set_updated_at
  before update on public.email_templates
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- email_logs
-- ---------------------------------------------------------------------------

create table public.email_logs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete cascade,
  template_id uuid references public.email_templates (id) on delete set null,
  recipient_email text not null,
  subject text,
  status public.delivery_status not null default 'queued',
  error_message text,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

comment on table public.email_logs is 'Send log for every transactional/marketing email.';

create index email_logs_business_id_idx on public.email_logs (business_id);

-- ---------------------------------------------------------------------------
-- device_tokens (push notification targets)
-- ---------------------------------------------------------------------------

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  platform public.device_platform not null default 'web',
  token text not null,
  is_active boolean not null default true,
  last_used_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (profile_id, token)
);

comment on table public.device_tokens is 'Push notification device tokens registered by a user.';

create index device_tokens_profile_id_idx on public.device_tokens (profile_id);

create trigger set_updated_at
  before update on public.device_tokens
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.notifications enable row level security;
alter table public.notification_logs enable row level security;
alter table public.email_templates enable row level security;
alter table public.email_logs enable row level security;
alter table public.device_tokens enable row level security;

create policy "notifications_select_own" on public.notifications
  for select using (recipient_profile_id = auth.uid() or public.is_super_admin());

create policy "notifications_update_own" on public.notifications
  for update using (recipient_profile_id = auth.uid() or public.is_super_admin());

create policy "notifications_insert_member" on public.notifications
  for insert with check (
    public.is_super_admin()
    or recipient_profile_id = auth.uid()
    or (business_id is not null and public.is_business_member(business_id))
  );

create policy "notification_logs_select_member" on public.notification_logs
  for select using (
    public.is_super_admin() or (business_id is not null and public.is_business_member(business_id))
  );

create policy "notification_logs_insert_member" on public.notification_logs
  for insert with check (
    public.is_super_admin() or (business_id is not null and public.is_business_member(business_id))
  );

create policy "email_templates_select_public_or_member" on public.email_templates
  for select using (
    business_id is null or public.is_business_member(business_id) or public.is_super_admin()
  );

create policy "email_templates_insert_manager" on public.email_templates
  for insert with check (
    public.is_super_admin() or (business_id is not null and public.is_business_manager(business_id))
  );

create policy "email_templates_update_manager" on public.email_templates
  for update using (
    public.is_super_admin() or (business_id is not null and public.is_business_manager(business_id))
  );

create policy "email_logs_select_member" on public.email_logs
  for select using (
    public.is_super_admin() or (business_id is not null and public.is_business_member(business_id))
  );

create policy "email_logs_insert_member" on public.email_logs
  for insert with check (
    public.is_super_admin() or (business_id is not null and public.is_business_member(business_id))
  );

create policy "device_tokens_select_own" on public.device_tokens
  for select using (profile_id = auth.uid() or public.is_super_admin());

create policy "device_tokens_insert_own" on public.device_tokens
  for insert with check (profile_id = auth.uid() or public.is_super_admin());

create policy "device_tokens_update_own" on public.device_tokens
  for update using (profile_id = auth.uid() or public.is_super_admin());

create policy "device_tokens_delete_own" on public.device_tokens
  for delete using (profile_id = auth.uid() or public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 09. Subscriptions & billing (UI-only for now; Stripe wired later)
-- =============================================================================

create type public.subscription_plan as enum ('free', 'starter', 'pro', 'enterprise');
create type public.subscription_status as enum ('trialing', 'active', 'past_due', 'canceled', 'expired');
create type public.payment_status as enum ('pending', 'paid', 'failed', 'refunded');

-- ---------------------------------------------------------------------------
-- subscriptions (1:1 with businesses)
-- ---------------------------------------------------------------------------

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null unique references public.businesses (id) on delete cascade,
  plan public.subscription_plan not null default 'free',
  status public.subscription_status not null default 'active',
  current_period_start timestamptz not null default now(),
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  trial_ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.subscriptions is 'Current subscription plan/status of a business. Payment provider wiring (Stripe) added later.';

create trigger set_updated_at
  before update on public.subscriptions
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_business_subscription()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.subscriptions (business_id, plan, status)
  values (new.id, 'free', 'active');
  return new;
end;
$$;

create trigger on_business_created_subscription
  after insert on public.businesses
  for each row execute function public.handle_new_business_subscription();

-- ---------------------------------------------------------------------------
-- subscription_history
-- ---------------------------------------------------------------------------

create table public.subscription_history (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  subscription_id uuid references public.subscriptions (id) on delete set null,
  from_plan public.subscription_plan,
  to_plan public.subscription_plan not null,
  changed_by uuid references public.profiles (id) on delete set null,
  reason text,
  created_at timestamptz not null default now()
);

comment on table public.subscription_history is 'Audit trail of plan changes (upgrades/downgrades) for a business.';

create index subscription_history_business_id_idx on public.subscription_history (business_id);

-- Automatically log every plan change.
create or replace function public.log_subscription_plan_change()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.plan is distinct from old.plan then
    insert into public.subscription_history (business_id, subscription_id, from_plan, to_plan)
    values (new.business_id, new.id, old.plan, new.plan);
  end if;
  return new;
end;
$$;

create trigger on_subscription_plan_changed
  after update on public.subscriptions
  for each row execute function public.log_subscription_plan_change();

-- ---------------------------------------------------------------------------
-- payment_history (placeholder table for future Stripe integration)
-- ---------------------------------------------------------------------------

create table public.payment_history (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  subscription_id uuid references public.subscriptions (id) on delete set null,
  amount numeric(10, 2) not null,
  currency text not null default 'EUR',
  status public.payment_status not null default 'pending',
  provider text not null default 'stripe',
  provider_reference text,
  paid_at timestamptz,
  created_at timestamptz not null default now()
);

comment on table public.payment_history is 'Payment/invoice records. Populated once Stripe is integrated.';

create index payment_history_business_id_idx on public.payment_history (business_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.subscriptions enable row level security;
alter table public.subscription_history enable row level security;
alter table public.payment_history enable row level security;

create policy "subscriptions_select_member" on public.subscriptions
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "subscriptions_update_owner" on public.subscriptions
  for update using (public.get_business_role(business_id) = 'owner' or public.is_super_admin());

create policy "subscription_history_select_member" on public.subscription_history
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "payment_history_select_owner" on public.payment_history
  for select using (public.get_business_role(business_id) = 'owner' or public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 10. Analytics rollups & system/audit logs
-- =============================================================================

-- ---------------------------------------------------------------------------
-- analytics_daily
-- ---------------------------------------------------------------------------

create table public.analytics_daily (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  date date not null,
  new_customers integer not null default 0,
  total_visits integer not null default 0,
  points_issued numeric(12, 2) not null default 0,
  points_redeemed numeric(12, 2) not null default 0,
  rewards_redeemed integer not null default 0,
  revenue numeric(12, 2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, date)
);

comment on table public.analytics_daily is 'Daily rollup metrics per business, populated by the daily analytics edge function.';

create index analytics_daily_business_id_idx on public.analytics_daily (business_id, date desc);

create trigger set_updated_at
  before update on public.analytics_daily
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- analytics_monthly
-- ---------------------------------------------------------------------------

create table public.analytics_monthly (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  year integer not null,
  month integer not null,
  new_customers integer not null default 0,
  total_visits integer not null default 0,
  points_issued numeric(12, 2) not null default 0,
  points_redeemed numeric(12, 2) not null default 0,
  rewards_redeemed integer not null default 0,
  revenue numeric(12, 2) not null default 0,
  returning_customers integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (business_id, year, month),
  constraint analytics_monthly_month_range check (month between 1 and 12)
);

comment on table public.analytics_monthly is 'Monthly rollup metrics per business, populated by the monthly analytics edge function.';

create index analytics_monthly_business_id_idx on public.analytics_monthly (business_id, year desc, month desc);

create trigger set_updated_at
  before update on public.analytics_monthly
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- activity_logs (human-readable business activity feed)
-- ---------------------------------------------------------------------------

create table public.activity_logs (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses (id) on delete cascade,
  actor_profile_id uuid references public.profiles (id) on delete set null,
  customer_id uuid references public.customers (id) on delete set null,
  action text not null,
  description text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

comment on table public.activity_logs is 'Human-readable activity feed shown on the dashboard ("Ana redeemed X").';

create index activity_logs_business_id_idx on public.activity_logs (business_id, created_at desc);

-- ---------------------------------------------------------------------------
-- audit_logs (security/compliance audit trail — super admin visibility)
-- ---------------------------------------------------------------------------

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_profile_id uuid references public.profiles (id) on delete set null,
  business_id uuid references public.businesses (id) on delete set null,
  action text not null,
  entity_type text,
  entity_id uuid,
  old_data jsonb,
  new_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

comment on table public.audit_logs is 'Security/compliance audit trail. Written by services and readable only by super admins.';

create index audit_logs_business_id_idx on public.audit_logs (business_id, created_at desc);
create index audit_logs_actor_idx on public.audit_logs (actor_profile_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.analytics_daily enable row level security;
alter table public.analytics_monthly enable row level security;
alter table public.activity_logs enable row level security;
alter table public.audit_logs enable row level security;

create policy "analytics_daily_select_member" on public.analytics_daily
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "analytics_monthly_select_member" on public.analytics_monthly
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "activity_logs_select_member" on public.activity_logs
  for select using (public.is_business_member(business_id) or public.is_super_admin());

create policy "activity_logs_insert_member" on public.activity_logs
  for insert with check (public.is_business_member(business_id) or public.is_super_admin());

-- audit_logs: super admin only (writes happen via service role, which bypasses RLS).
create policy "audit_logs_select_super_admin" on public.audit_logs
  for select using (public.is_super_admin());

-- =============================================================================
-- LoyalFlow — 11. Platform: support tickets, system settings, storage file registry
-- =============================================================================

create type public.support_ticket_status as enum ('open', 'in_progress', 'resolved', 'closed');
create type public.support_ticket_priority as enum ('low', 'medium', 'high', 'urgent');

-- ---------------------------------------------------------------------------
-- support_tickets
-- ---------------------------------------------------------------------------

create table public.support_tickets (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete set null,
  profile_id uuid references public.profiles (id) on delete set null,
  subject text not null,
  message text not null,
  status public.support_ticket_status not null default 'open',
  priority public.support_ticket_priority not null default 'medium',
  assigned_to uuid references public.profiles (id) on delete set null,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.support_tickets is 'Customer/business support requests handled by the platform team.';

create index support_tickets_business_id_idx on public.support_tickets (business_id);
create index support_tickets_profile_id_idx on public.support_tickets (profile_id);
create index support_tickets_status_idx on public.support_tickets (status);

create trigger set_updated_at
  before update on public.support_tickets
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- system_settings (super-admin managed key/value store)
-- ---------------------------------------------------------------------------

create table public.system_settings (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  value jsonb not null default '{}'::jsonb,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.system_settings is 'Platform-wide configuration key/value store, managed by super admins.';

create trigger set_updated_at
  before update on public.system_settings
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- storage_files (metadata registry for files uploaded to Storage buckets)
-- ---------------------------------------------------------------------------

create table public.storage_files (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses (id) on delete cascade,
  profile_id uuid references public.profiles (id) on delete set null,
  bucket text not null,
  path text not null,
  file_name text not null,
  mime_type text,
  size_bytes bigint,
  created_at timestamptz not null default now(),
  unique (bucket, path)
);

comment on table public.storage_files is 'Metadata registry (owner, size, mime type) mirroring files kept in Supabase Storage.';

create index storage_files_business_id_idx on public.storage_files (business_id);
create index storage_files_profile_id_idx on public.storage_files (profile_id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.support_tickets enable row level security;
alter table public.system_settings enable row level security;
alter table public.storage_files enable row level security;

create policy "support_tickets_select_own_or_member_or_admin" on public.support_tickets
  for select using (
    profile_id = auth.uid()
    or public.is_super_admin()
    or (business_id is not null and public.is_business_manager(business_id))
  );

create policy "support_tickets_insert_own" on public.support_tickets
  for insert with check (profile_id = auth.uid() or public.is_super_admin());

create policy "support_tickets_update_admin" on public.support_tickets
  for update using (public.is_super_admin());

-- system_settings: super admin only.
create policy "system_settings_select_super_admin" on public.system_settings
  for select using (public.is_super_admin());

create policy "system_settings_write_super_admin" on public.system_settings
  for all using (public.is_super_admin()) with check (public.is_super_admin());

create policy "storage_files_select_own_or_member" on public.storage_files
  for select using (
    profile_id = auth.uid()
    or public.is_super_admin()
    or (business_id is not null and public.is_business_member(business_id))
  );

create policy "storage_files_insert_own_or_member" on public.storage_files
  for insert with check (
    profile_id = auth.uid()
    or public.is_super_admin()
    or (business_id is not null and public.is_business_member(business_id))
  );

create policy "storage_files_delete_own_or_manager" on public.storage_files
  for delete using (
    profile_id = auth.uid()
    or public.is_super_admin()
    or (business_id is not null and public.is_business_manager(business_id))
  );

-- =============================================================================
-- LoyalFlow — 12. Storage buckets & policies
-- =============================================================================
--
-- Path convention for every bucket: the first path segment identifies the
-- owning scope so storage.foldername(name)[1] can be used in policies:
--   avatars/{profile_id}/...
--   business-logos/{business_id}/...
--   reward-images/{business_id}/...
--   campaign-images/{business_id}/...
--   documents/{business_id}/...
--   attachments/{business_id}/...

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('business-logos', 'business-logos', true, 5242880, array['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml']),
  ('reward-images', 'reward-images', true, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('campaign-images', 'campaign-images', true, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('documents', 'documents', false, 20971520, null),
  ('attachments', 'attachments', false, 20971520, null)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- avatars — public read, owner (matching profile id folder) writes
-- ---------------------------------------------------------------------------

create policy "avatars_public_read" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "avatars_owner_write" on storage.objects
  for insert with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars_owner_update" on storage.objects
  for update using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars_owner_delete" on storage.objects
  for delete using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------------
-- business-logos — public read, business managers write
-- ---------------------------------------------------------------------------

create policy "business_logos_public_read" on storage.objects
  for select using (bucket_id = 'business-logos');

create policy "business_logos_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'business-logos'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "business_logos_manager_update" on storage.objects
  for update using (
    bucket_id = 'business-logos'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "business_logos_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'business-logos'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- reward-images — public read, business managers write
-- ---------------------------------------------------------------------------

create policy "reward_images_public_read" on storage.objects
  for select using (bucket_id = 'reward-images');

create policy "reward_images_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'reward-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "reward_images_manager_update" on storage.objects
  for update using (
    bucket_id = 'reward-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "reward_images_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'reward-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- campaign-images — members read, managers write
-- ---------------------------------------------------------------------------

create policy "campaign_images_member_read" on storage.objects
  for select using (
    bucket_id = 'campaign-images'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "campaign_images_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'campaign-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "campaign_images_manager_update" on storage.objects
  for update using (
    bucket_id = 'campaign-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "campaign_images_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'campaign-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- documents — private, business members only
-- ---------------------------------------------------------------------------

create policy "documents_member_read" on storage.objects
  for select using (
    bucket_id = 'documents'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "documents_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'documents'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "documents_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'documents'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- attachments — private, business members only (support tickets, feedback, ...)
-- ---------------------------------------------------------------------------

create policy "attachments_member_read" on storage.objects
  for select using (
    bucket_id = 'attachments'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "attachments_member_write" on storage.objects
  for insert with check (
    bucket_id = 'attachments'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "attachments_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'attachments'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- =============================================================================
-- LoyalFlow — 13. Auto-create a business at signup time (from auth metadata)
-- =============================================================================
--
-- The Register page calls supabase.auth.signUp(email, password, { data: { business_name } }).
-- This trigger reads that metadata and creates the business immediately when the
-- auth.users row is inserted — regardless of whether email confirmation is
-- enabled on the project, since confirmation only gates login, not user creation.
--
-- Trigger firing order on auth.users (Postgres fires same-event triggers in
-- alphabetical order by name): "on_auth_user_created" (creates the profile,
-- defined in migration 02) must run before "on_auth_user_created_business"
-- (this one), because businesses.owner_id references profiles(id).

create or replace function public.slugify(input text)
returns text
language sql
immutable
as $$
  select trim(both '-' from regexp_replace(lower(trim(input)), '[^a-z0-9]+', '-', 'g'));
$$;

comment on function public.slugify(text) is 'Lowercases and dashes a string for use as a URL-safe slug.';

create or replace function public.handle_new_user_business()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  business_name text;
  business_category text;
  business_city text;
  final_slug text;
begin
  business_name := new.raw_user_meta_data ->> 'business_name';

  if business_name is null or length(trim(business_name)) = 0 then
    return new;
  end if;

  business_category := coalesce(new.raw_user_meta_data ->> 'business_category', 'other');
  business_city := nullif(trim(new.raw_user_meta_data ->> 'business_city'), '');
  final_slug := public.slugify(business_name) || '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 6);

  insert into public.businesses (owner_id, name, slug, category, city)
  values (new.id, business_name, final_slug, business_category::public.business_category, business_city);

  return new;
end;
$$;

create trigger on_auth_user_created_business
  after insert on auth.users
  for each row execute function public.handle_new_user_business();

-- =============================================================================
-- LoyalFlow — 14. Customer self-service: directory browsing + self-enrollment
-- =============================================================================
--
-- Lets any authenticated user (not yet a customer or member of a business)
-- browse active businesses/programs/rewards to decide where to enroll, and
-- create their own customers/loyalty_cards rows. Guests (unauthenticated)
-- still see nothing — every policy below requires auth.uid() is not null.

create policy "businesses_select_directory" on public.businesses
  for select using (is_active = true and auth.uid() is not null);

create policy "loyalty_programs_select_directory" on public.loyalty_programs
  for select using (is_active = true and auth.uid() is not null);

create policy "reward_catalog_select_directory" on public.reward_catalog
  for select using (is_active = true and auth.uid() is not null);

create policy "customers_insert_self" on public.customers
  for insert with check (profile_id = auth.uid());

create policy "loyalty_cards_insert_self" on public.loyalty_cards
  for insert with check (public.is_own_customer(customer_id));

