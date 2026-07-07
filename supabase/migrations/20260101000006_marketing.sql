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
