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
