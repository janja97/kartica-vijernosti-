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
