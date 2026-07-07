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
