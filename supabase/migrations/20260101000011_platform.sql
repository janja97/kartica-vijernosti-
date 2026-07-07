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
