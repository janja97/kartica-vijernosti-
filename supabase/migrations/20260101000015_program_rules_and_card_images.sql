-- =============================================================================
-- LoyalFlow — 15. Loyalty program earning rules, card images, expiry helper
-- =============================================================================
--
-- Adds a third, additive earning rule to loyalty_programs (a one-off bonus for
-- spending at least a given amount in a single visit — on top of the existing
-- points_per_visit / points_per_currency rules, which already combine), an
-- optional custom card image per program, and a helper function used to lazily
-- expire a loyalty card (void its points, mark it expired) the next time it is
-- read or scanned after its expiry date has passed.

alter table public.loyalty_programs
  add column if not exists image_url text,
  add column if not exists minimum_spend_amount numeric(10, 2),
  add column if not exists minimum_spend_bonus numeric(10, 2);

comment on column public.loyalty_programs.image_url is 'Optional custom background image for this program''s digital card. Falls back to the business logo, then a preset gradient, when null.';
comment on column public.loyalty_programs.minimum_spend_amount is 'If set, a visit with amount_spent >= this value earns an extra minimum_spend_bonus on top of points_per_visit/points_per_currency.';
comment on column public.loyalty_programs.minimum_spend_bonus is 'Bonus points granted when a visit''s amount_spent reaches minimum_spend_amount.';

alter table public.loyalty_programs
  add constraint loyalty_programs_minimum_spend_pair check (
    (minimum_spend_amount is null) = (minimum_spend_bonus is null)
  );

-- ---------------------------------------------------------------------------
-- expire_loyalty_card_if_due — lazily void points + mark a card expired
-- ---------------------------------------------------------------------------
-- Called from the app (not a cron job) whenever a card is read or scanned.
-- Safe to call repeatedly: it's a no-op once the card is already expired or
-- has no expiry date set.

create or replace function public.expire_loyalty_card_if_due(target_card_id uuid)
returns void
language plpgsql
security definer set search_path = public
as $$
declare
  card record;
begin
  select id, business_id, customer_id, current_points, status, expires_at
  into card
  from public.loyalty_cards
  where id = target_card_id
  for update;

  if not found then
    return;
  end if;

  if card.status <> 'active' or card.expires_at is null or card.expires_at > now() then
    return;
  end if;

  if card.current_points > 0 then
    insert into public.point_transactions (
      business_id, loyalty_card_id, customer_id, type, points, balance_after, reference_type, note
    )
    values (
      card.business_id, card.id, card.customer_id, 'expire', -card.current_points, 0, 'card_expiry',
      'Kartica je istekla — bodovi automatski poništeni.'
    );
  end if;

  update public.loyalty_cards set status = 'expired' where id = card.id;
end;
$$;

comment on function public.expire_loyalty_card_if_due(uuid) is
  'Idempotent lazy sweep: if the card''s expiry date has passed, voids remaining points via an "expire" ledger entry and marks it expired. No-op otherwise.';
