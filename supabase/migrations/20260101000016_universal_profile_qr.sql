-- =============================================================================
-- LoyalFlow — 16. Universal profile-scoped QR + guest customer claiming
-- =============================================================================
--
-- Moves qr_codes from "one code per (business, customer)" to "one universal
-- code per profile" — any participating business can scan the same code to
-- recognize a person, auto-joining them to that business's loyalty program on
-- first scan. Also adds the two privileged helpers this unlocks:
--   - scan_resolve_profile: lets scanning staff resolve a code to a stranger's
--     name/email, narrowly, without a broad SELECT grant on qr_codes/profiles.
--   - claim_guest_customers: lets a newly-verified guest attach their real
--     profile_id to any guest customers rows a business created for their
--     email before they ever verified.
--
-- No production customer data exists yet, so old per-business QR codes are
-- reissued rather than preserved.

-- ---------------------------------------------------------------------------
-- Retire the old per-(business, customer) issuance
-- ---------------------------------------------------------------------------

drop trigger if exists on_customer_created_qr on public.customers;
drop function if exists public.handle_new_customer_qr();

drop policy if exists "qr_codes_select_member_or_self" on public.qr_codes;
drop policy if exists "qr_codes_insert_member" on public.qr_codes;
drop policy if exists "qr_codes_update_member" on public.qr_codes;

-- ---------------------------------------------------------------------------
-- qr_codes: business_id/customer_id -> profile_id
-- ---------------------------------------------------------------------------

alter table public.qr_codes add column profile_id uuid references public.profiles (id) on delete cascade;

alter table public.qr_codes drop constraint qr_codes_business_id_customer_id_key;
drop index if exists public.qr_codes_business_id_idx;
drop index if exists public.qr_codes_customer_id_idx;
alter table public.qr_codes drop column business_id;
alter table public.qr_codes drop column customer_id;

alter table public.qr_codes alter column profile_id set not null;
alter table public.qr_codes add constraint qr_codes_profile_id_key unique (profile_id);

comment on table public.qr_codes is 'The universal QR token used to identify a person (by profile) when scanned at any participating business.';

-- Auto-issue a universal QR code whenever a profile is created — fires for
-- every signup path (password, Google OAuth, and OTP-verified guests alike),
-- since all of them insert into public.profiles via the existing
-- handle_new_user() trigger.
create or replace function public.handle_new_profile_qr()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.qr_codes (profile_id, code)
  values (new.id, replace(gen_random_uuid()::text, '-', ''))
  on conflict (profile_id) do nothing;
  return new;
end;
$$;

create trigger on_profile_created_qr
  after insert on public.profiles
  for each row execute function public.handle_new_profile_qr();

-- Backfill: issue a code for every existing profile that doesn't have one yet.
insert into public.qr_codes (profile_id, code)
select p.id, replace(gen_random_uuid()::text, '-', '')
from public.profiles p
where not exists (select 1 from public.qr_codes qc where qc.profile_id = p.id);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
-- Deliberately narrow: a person can read their own QR row (to display it in
-- the portal); no business-member SELECT grant, since scanning staff resolve
-- a code through scan_resolve_profile() below, not by browsing this table.

create policy "qr_codes_select_own_or_admin" on public.qr_codes
  for select using (profile_id = auth.uid() or public.is_super_admin());

-- ---------------------------------------------------------------------------
-- scan_resolve_profile — narrow, audited stranger-lookup for scanning staff
-- ---------------------------------------------------------------------------

create or replace function public.scan_resolve_profile(target_code text, target_business_id uuid)
returns table (
  profile_id uuid,
  first_name text,
  last_name text,
  email text,
  already_customer boolean
)
language plpgsql
stable
security definer set search_path = public
as $$
begin
  if not public.is_business_member(target_business_id) then
    raise exception 'not_business_member' using errcode = 'P0001';
  end if;

  return query
    select
      p.id,
      p.first_name,
      p.last_name,
      p.email,
      exists (
        select 1 from public.customers c
        where c.business_id = target_business_id and c.profile_id = p.id
      )
    from public.qr_codes qc
    join public.profiles p on p.id = qc.profile_id
    where qc.code = target_code and qc.is_active;
end;
$$;

comment on function public.scan_resolve_profile(text, uuid) is
  'Resolves a universal QR code to the person''s profile for a scanning business member. The one narrow, audited place a stranger''s name/email becomes visible to staff — callers must already be a member of target_business_id.';

-- ---------------------------------------------------------------------------
-- claim_guest_customers — attach a verified profile to pre-existing guest rows
-- ---------------------------------------------------------------------------

create or replace function public.claim_guest_customers()
returns integer
language plpgsql
security definer set search_path = public
as $$
declare
  v_email text;
  v_count integer;
begin
  select email into v_email from public.profiles where id = auth.uid();

  if v_email is null then
    return 0;
  end if;

  update public.customers c
  set profile_id = auth.uid()
  where c.profile_id is null
    and lower(c.email) = lower(v_email)
    and not exists (
      select 1 from public.customers c2
      where c2.business_id = c.business_id and c2.profile_id = auth.uid()
    );

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

comment on function public.claim_guest_customers() is
  'Called right after a guest verifies their OTP code: attaches auth.uid() to any customers row a business created for their email before they had a real profile. Skips a business where the caller already has a distinct customer row, to avoid violating customers_business_profile_unique.';
