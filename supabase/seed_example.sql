-- =============================================================================
-- LoyalFlow — optional example data
-- =============================================================================
--
-- Run this AFTER you have registered at least one real account through the
-- app's Register page (schema.sql must already be applied, and a row must
-- exist in `businesses`). This script does not touch auth.users — Supabase
-- does not support creating real auth users safely from plain SQL (passwords
-- and confirmation tokens are managed by GoTrue, not by direct inserts), so
-- the only correct way to get a real owner account is to sign up through the
-- app itself.
--
-- Step 1: find your business_id
--   select id, name from public.businesses;
--
-- Step 2: paste that id below, replacing the placeholder, then run this
-- whole file in the Supabase SQL Editor.

do $$
declare
  v_business_id uuid := '00000000-0000-0000-0000-000000000000'; -- <-- replace me
  v_program_id uuid;
  v_customer_id uuid;
  v_card_id uuid;
  v_names text[] := array['Ana Anić', 'Marko Marić', 'Ivana Kovač', 'Petra Perić', 'Josip Novak'];
  v_name text;
  v_points numeric(12, 2);
begin
  if not exists (select 1 from public.businesses where id = v_business_id) then
    raise exception 'No business found with id %. Update v_business_id in this script first.', v_business_id;
  end if;

  insert into public.loyalty_programs (business_id, name, description, type, points_per_visit, points_per_currency)
  values (v_business_id, 'Kartica vjernosti', 'Skupljaj bodove pri svakoj posjeti.', 'points', 10, 1)
  returning id into v_program_id;

  foreach v_name in array v_names loop
    insert into public.customers (business_id, first_name, last_name)
    values (v_business_id, split_part(v_name, ' ', 1), split_part(v_name, ' ', 2))
    returning id into v_customer_id;

    insert into public.loyalty_cards (business_id, customer_id, loyalty_program_id, card_number)
    values (v_business_id, v_customer_id, v_program_id, upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10)))
    returning id into v_card_id;

    v_points := (random() * 500 + 50)::numeric(12, 2);

    insert into public.point_transactions (business_id, loyalty_card_id, customer_id, type, points, balance_after, reference_type)
    values (v_business_id, v_card_id, v_customer_id, 'earn', v_points, v_points, 'seed');

    insert into public.customer_visits (business_id, customer_id, loyalty_card_id, points_earned, visited_at)
    values (v_business_id, v_customer_id, v_card_id, v_points, now() - (random() * interval '5 days'));
  end loop;
end $$;
