-- =============================================================================
-- LoyalFlow — 17. Reward program scoping + goal reward
-- =============================================================================
--
-- Adds an explicit "goal reward" concept per loyalty program: a business owner
-- deliberately designates one reward as the program's completion goal. This is
-- intentionally NOT inferred from "cheapest active reward" (the existing UI
-- convention used for the progress-ring goal) — that would silently archive a
-- card the moment a customer crosses the price of the cheapest reward,
-- discarding progress toward a pricier one they may have been saving for.

alter table public.reward_catalog add column is_goal boolean not null default false;

alter table public.reward_catalog
  add constraint reward_catalog_goal_requires_program check (
    not is_goal or loyalty_program_id is not null
  );

create unique index reward_catalog_one_goal_per_program
  on public.reward_catalog (loyalty_program_id)
  where is_goal and loyalty_program_id is not null;

comment on column public.reward_catalog.is_goal is
  'True if this reward is the program''s designated completion goal — reaching it lets staff archive the card and start a fresh one via redeem_goal_and_reset_card().';
