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
