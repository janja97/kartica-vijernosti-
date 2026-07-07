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
