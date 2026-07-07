-- =============================================================================
-- LoyalFlow — 14. Customer self-service: directory browsing + self-enrollment
-- =============================================================================
--
-- Lets any authenticated user (not yet a customer or member of a business)
-- browse active businesses/programs/rewards to decide where to enroll, and
-- create their own customers/loyalty_cards rows. Guests (unauthenticated)
-- still see nothing — every policy below requires auth.uid() is not null.

create policy "businesses_select_directory" on public.businesses
  for select using (is_active = true and auth.uid() is not null);

create policy "loyalty_programs_select_directory" on public.loyalty_programs
  for select using (is_active = true and auth.uid() is not null);

create policy "reward_catalog_select_directory" on public.reward_catalog
  for select using (is_active = true and auth.uid() is not null);

create policy "customers_insert_self" on public.customers
  for insert with check (profile_id = auth.uid());

create policy "loyalty_cards_insert_self" on public.loyalty_cards
  for insert with check (public.is_own_customer(customer_id));
