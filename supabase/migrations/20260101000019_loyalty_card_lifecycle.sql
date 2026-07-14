-- =============================================================================
-- LoyalFlow — 19. Loyalty card lifecycle: archive-on-goal + fresh card
-- =============================================================================
--
-- Replaces the flat "exactly one card per (customer, program), forever" rule
-- with "at most one *active/suspended* card per (customer, program)" — once a
-- card is archived (completed) or expires, a fresh card can start for the same
-- pairing. Adds redeem_goal_and_reset_card(), the atomic primitive that
-- fulfills a program's goal reward and performs the archive+recreate as one
-- transaction (mirrors the existing expire_loyalty_card_if_due idiom).

alter table public.loyalty_cards drop constraint loyalty_cards_customer_id_loyalty_program_id_key;

create unique index loyalty_cards_active_customer_program_unique
  on public.loyalty_cards (customer_id, loyalty_program_id)
  where status in ('active', 'suspended');

create or replace function public.redeem_goal_and_reset_card(
  target_card_id uuid,
  target_reward_id uuid,
  target_redeemed_by uuid
)
returns public.loyalty_cards
language plpgsql
security definer set search_path = public
as $$
declare
  card record;
  reward record;
  new_card public.loyalty_cards;
  v_expiry_days integer;
  v_expires_at timestamptz;
begin
  select * into card from public.loyalty_cards where id = target_card_id for update;
  if not found then
    raise exception 'card_not_found' using errcode = 'P0001';
  end if;

  if not public.is_business_member(card.business_id) then
    raise exception 'not_business_member' using errcode = 'P0001';
  end if;

  if card.status <> 'active' then
    raise exception 'card_not_active' using errcode = 'P0001';
  end if;

  select * into reward from public.reward_catalog where id = target_reward_id;
  if not found or not reward.is_goal or reward.loyalty_program_id is distinct from card.loyalty_program_id then
    raise exception 'not_goal_reward' using errcode = 'P0001';
  end if;

  if reward.points_cost is null or card.current_points < reward.points_cost then
    raise exception 'goal_not_reached' using errcode = 'P0001';
  end if;

  insert into public.reward_redemptions (
    business_id, customer_id, reward_id, loyalty_card_id, points_spent, status, redeemed_by, redeemed_at
  ) values (
    card.business_id, card.customer_id, target_reward_id, card.id, reward.points_cost, 'fulfilled', target_redeemed_by, now()
  );

  insert into public.point_transactions (
    business_id, loyalty_card_id, customer_id, type, points, balance_after, reference_type, created_by
  ) values (
    card.business_id, card.id, card.customer_id, 'redeem', -reward.points_cost, card.current_points - reward.points_cost,
    'goal_redemption', target_redeemed_by
  );

  update public.loyalty_cards set status = 'completed' where id = card.id;

  select expiry_days into v_expiry_days from public.loyalty_programs where id = card.loyalty_program_id;
  v_expires_at := case when v_expiry_days is not null then now() + make_interval(days => v_expiry_days) else null end;

  insert into public.loyalty_cards (business_id, customer_id, loyalty_program_id, card_number, expires_at)
  values (
    card.business_id,
    card.customer_id,
    card.loyalty_program_id,
    'LF-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
    v_expires_at
  )
  returning * into new_card;

  return new_card;
end;
$$;

comment on function public.redeem_goal_and_reset_card(uuid, uuid, uuid) is
  'Atomically fulfills a program''s designated goal reward for a card, archives that card as completed, and issues a fresh active card for the same customer+program at zero points.';
