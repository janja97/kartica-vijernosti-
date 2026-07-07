-- =============================================================================
-- LoyalFlow — 12. Storage buckets & policies
-- =============================================================================
--
-- Path convention for every bucket: the first path segment identifies the
-- owning scope so storage.foldername(name)[1] can be used in policies:
--   avatars/{profile_id}/...
--   business-logos/{business_id}/...
--   reward-images/{business_id}/...
--   campaign-images/{business_id}/...
--   documents/{business_id}/...
--   attachments/{business_id}/...

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('business-logos', 'business-logos', true, 5242880, array['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml']),
  ('reward-images', 'reward-images', true, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('campaign-images', 'campaign-images', true, 5242880, array['image/png', 'image/jpeg', 'image/webp']),
  ('documents', 'documents', false, 20971520, null),
  ('attachments', 'attachments', false, 20971520, null)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- avatars — public read, owner (matching profile id folder) writes
-- ---------------------------------------------------------------------------

create policy "avatars_public_read" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "avatars_owner_write" on storage.objects
  for insert with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars_owner_update" on storage.objects
  for update using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "avatars_owner_delete" on storage.objects
  for delete using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ---------------------------------------------------------------------------
-- business-logos — public read, business managers write
-- ---------------------------------------------------------------------------

create policy "business_logos_public_read" on storage.objects
  for select using (bucket_id = 'business-logos');

create policy "business_logos_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'business-logos'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "business_logos_manager_update" on storage.objects
  for update using (
    bucket_id = 'business-logos'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "business_logos_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'business-logos'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- reward-images — public read, business managers write
-- ---------------------------------------------------------------------------

create policy "reward_images_public_read" on storage.objects
  for select using (bucket_id = 'reward-images');

create policy "reward_images_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'reward-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "reward_images_manager_update" on storage.objects
  for update using (
    bucket_id = 'reward-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "reward_images_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'reward-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- campaign-images — members read, managers write
-- ---------------------------------------------------------------------------

create policy "campaign_images_member_read" on storage.objects
  for select using (
    bucket_id = 'campaign-images'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "campaign_images_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'campaign-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "campaign_images_manager_update" on storage.objects
  for update using (
    bucket_id = 'campaign-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "campaign_images_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'campaign-images'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- documents — private, business members only
-- ---------------------------------------------------------------------------

create policy "documents_member_read" on storage.objects
  for select using (
    bucket_id = 'documents'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "documents_manager_write" on storage.objects
  for insert with check (
    bucket_id = 'documents'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

create policy "documents_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'documents'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );

-- ---------------------------------------------------------------------------
-- attachments — private, business members only (support tickets, feedback, ...)
-- ---------------------------------------------------------------------------

create policy "attachments_member_read" on storage.objects
  for select using (
    bucket_id = 'attachments'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "attachments_member_write" on storage.objects
  for insert with check (
    bucket_id = 'attachments'
    and public.is_business_member(((storage.foldername(name))[1])::uuid)
  );

create policy "attachments_manager_delete" on storage.objects
  for delete using (
    bucket_id = 'attachments'
    and public.is_business_manager(((storage.foldername(name))[1])::uuid)
  );
