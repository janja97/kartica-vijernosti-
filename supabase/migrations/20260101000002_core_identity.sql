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
