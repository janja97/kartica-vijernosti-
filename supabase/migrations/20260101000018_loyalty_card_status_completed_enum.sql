-- =============================================================================
-- LoyalFlow — 18. loyalty_card_status: add 'completed' value
-- =============================================================================
--
-- Must be its own migration file/transaction: Postgres forbids referencing a
-- newly added enum value before the ALTER TYPE ... ADD VALUE has committed.
-- The next migration (19) is the first to actually use 'completed'.

alter type public.loyalty_card_status add value 'completed';
