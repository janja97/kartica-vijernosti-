-- =============================================================================
-- LoyalFlow — 13. Auto-create a business at signup time (from auth metadata)
-- =============================================================================
--
-- The Register page calls supabase.auth.signUp(email, password, { data: { business_name } }).
-- This trigger reads that metadata and creates the business immediately when the
-- auth.users row is inserted — regardless of whether email confirmation is
-- enabled on the project, since confirmation only gates login, not user creation.
--
-- Trigger firing order on auth.users (Postgres fires same-event triggers in
-- alphabetical order by name): "on_auth_user_created" (creates the profile,
-- defined in migration 02) must run before "on_auth_user_created_business"
-- (this one), because businesses.owner_id references profiles(id).

create or replace function public.slugify(input text)
returns text
language sql
immutable
as $$
  select trim(both '-' from regexp_replace(lower(trim(input)), '[^a-z0-9]+', '-', 'g'));
$$;

comment on function public.slugify(text) is 'Lowercases and dashes a string for use as a URL-safe slug.';

create or replace function public.handle_new_user_business()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  business_name text;
  business_category text;
  business_city text;
  final_slug text;
begin
  business_name := new.raw_user_meta_data ->> 'business_name';

  if business_name is null or length(trim(business_name)) = 0 then
    return new;
  end if;

  business_category := coalesce(new.raw_user_meta_data ->> 'business_category', 'other');
  business_city := nullif(trim(new.raw_user_meta_data ->> 'business_city'), '');
  final_slug := public.slugify(business_name) || '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 6);

  insert into public.businesses (owner_id, name, slug, category, city)
  values (new.id, business_name, final_slug, business_category::public.business_category, business_city);

  return new;
end;
$$;

create trigger on_auth_user_created_business
  after insert on auth.users
  for each row execute function public.handle_new_user_business();
