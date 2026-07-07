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
