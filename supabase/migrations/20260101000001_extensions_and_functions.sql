-- =============================================================================
-- LoyalFlow — 01. Extensions & generic helper functions
-- =============================================================================

create extension if not exists "pgcrypto" with schema public;

-- Generic trigger function: keeps `updated_at` in sync on every UPDATE.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'Sets updated_at = now() on row update. Attached as a BEFORE UPDATE trigger to every table that has an updated_at column.';
