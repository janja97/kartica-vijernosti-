import { CustomerRepository } from '@/repositories/CustomerRepository'
import { LoyaltyProgramRepository } from '@/repositories/LoyaltyProgramRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import { QrCodeRepository } from '@/repositories/QrCodeRepository'
import { RewardRedemptionRepository } from '@/repositories/RewardRedemptionRepository'
import { RewardRepository } from '@/repositories/RewardRepository'
import { createLoyaltyCardForProgram } from '@/services/shared/loyaltyCardCreation'
import type { Database } from '@/types/database.types'

type LoyaltyCardRow = Database['public']['Tables']['loyalty_cards']['Row']
type CustomerRow = Database['public']['Tables']['customers']['Row']

export interface PendingRedemptionSummary {
  id: string
  rewardName: string
  pointsSpent: number
}

export interface GoalRewardSummary {
  id: string
  name: string
  pointsCost: number
}

export interface ScanResult {
  kind: 'ready'
  customerId: string
  customerName: string
  cardId: string
  programName: string
  currentPoints: number
  nextRewardThreshold: number | null
  isExpired: boolean
  pendingRedemptions: PendingRedemptionSummary[]
  goalReward: GoalRewardSummary | null
  isGoalReached: boolean
}

export interface ProgramChoice {
  id: string
  name: string
}

export interface NewToBusinessResult {
  kind: 'new-to-business'
  profileId: string
  firstName: string
  lastName: string | null
  email: string
  programs: ProgramChoice[]
}

export interface CardChoice {
  cardId: string
  programId: string
  programName: string
}

export interface PickCardResult {
  kind: 'pick-card'
  customerId: string
  cards: CardChoice[]
}

export type ScanLookupResult = ScanResult | NewToBusinessResult | PickCardResult

function isDue(expiresAt: string | null, status: string): boolean {
  return status === 'active' && expiresAt !== null && new Date(expiresAt).getTime() < Date.now()
}

async function buildReadyResult(
  customer: CustomerRow,
  cardInput: LoyaltyCardRow,
  businessId: string,
): Promise<ScanResult> {
  let card = cardInput
  if (isDue(card.expires_at, card.status)) {
    await LoyaltyRepository.expireCardIfDue(card.id)
    const refreshed = await LoyaltyRepository.findCardById(card.id)
    if (refreshed) card = refreshed
  }

  const [pending, program, activeRewards] = await Promise.all([
    RewardRedemptionRepository.listPendingForCard(card.id),
    LoyaltyProgramRepository.findById(card.loyalty_program_id),
    RewardRepository.listActiveForBusiness(businessId),
  ])
  const rewards = await RewardRepository.findByIds(
    pending.map((redemption) => redemption.reward_id),
  )
  const rewardById = new Map(rewards.map((reward) => [reward.id, reward]))
  const nextRewardThreshold =
    activeRewards.find((reward) => reward.points_cost !== null)?.points_cost ?? null

  const goalRewardRow = activeRewards.find(
    (reward) => reward.is_goal && reward.loyalty_program_id === card.loyalty_program_id,
  )
  const goalReward =
    goalRewardRow && goalRewardRow.points_cost !== null
      ? { id: goalRewardRow.id, name: goalRewardRow.name, pointsCost: goalRewardRow.points_cost }
      : null

  return {
    kind: 'ready',
    customerId: customer.id,
    customerName: `${customer.first_name} ${customer.last_name ?? ''}`.trim(),
    cardId: card.id,
    programName: program?.name ?? '',
    currentPoints: card.current_points,
    nextRewardThreshold,
    isExpired: card.status === 'expired',
    pendingRedemptions: pending.map((redemption) => ({
      id: redemption.id,
      rewardName: rewardById.get(redemption.reward_id)?.name ?? 'Nagrada',
      pointsSpent: redemption.points_spent,
    })),
    goalReward,
    isGoalReached: goalReward !== null && card.current_points >= goalReward.pointsCost,
  }
}

export const scanService = {
  async lookupByCode(code: string, businessId: string): Promise<ScanLookupResult> {
    const resolved = await QrCodeRepository.resolveForScan(code, businessId)
    if (!resolved) throw new Error('QR kod nije prepoznat.')

    const firstName = resolved.first_name || resolved.email.split('@')[0] || 'Korisnik'

    if (resolved.already_customer) {
      const customer = await CustomerRepository.findByBusinessAndProfile(
        businessId,
        resolved.profile_id,
      )
      if (customer) {
        const allCards = await LoyaltyRepository.findCardsForCustomers([customer.id])
        const cards = allCards.filter((card) => card.status !== 'completed')

        if (cards.length === 1) {
          return buildReadyResult(customer, cards[0]!, businessId)
        }

        if (cards.length > 1) {
          const programs = await Promise.all(
            cards.map((card) => LoyaltyProgramRepository.findById(card.loyalty_program_id)),
          )
          return {
            kind: 'pick-card',
            customerId: customer.id,
            cards: cards.map((card, index) => ({
              cardId: card.id,
              programId: card.loyalty_program_id,
              programName: programs[index]?.name ?? '',
            })),
          }
        }
      }
    }

    const programs = await LoyaltyProgramRepository.listActiveForBusiness(businessId)
    if (programs.length === 0) {
      throw new Error('Ova tvrtka nema aktivan program vjernosti.')
    }

    if (programs.length === 1) {
      const { customer, card } = await scanService.joinAndCreateCard(
        resolved.profile_id,
        businessId,
        programs[0]!.id,
        firstName,
        resolved.last_name,
        resolved.email,
      )
      return buildReadyResult(customer, card, businessId)
    }

    return {
      kind: 'new-to-business',
      profileId: resolved.profile_id,
      firstName,
      lastName: resolved.last_name,
      email: resolved.email,
      programs: programs.map((program) => ({ id: program.id, name: program.name })),
    }
  },

  async joinAndCreateCard(
    profileId: string,
    businessId: string,
    programId: string,
    firstName: string,
    lastName: string | null,
    email: string,
  ): Promise<{ customer: CustomerRow; card: LoyaltyCardRow }> {
    let customer = await CustomerRepository.findByBusinessAndProfile(businessId, profileId)
    if (!customer) {
      customer = await CustomerRepository.createForBusiness(
        businessId,
        profileId,
        firstName,
        lastName,
        email,
      )
    }

    let card = await LoyaltyRepository.findActiveCardByCustomerAndProgram(customer.id, programId)
    if (!card) {
      card = await createLoyaltyCardForProgram(businessId, customer.id, programId)
    }

    return { customer, card }
  },

  async pickCard(customerId: string, cardId: string, businessId: string): Promise<ScanResult> {
    const customer = await CustomerRepository.findById(customerId)
    if (!customer) throw new Error('Korisnik nije pronađen.')
    const card = await LoyaltyRepository.findCardById(cardId)
    if (!card) throw new Error('Kartica nije pronađena.')
    return buildReadyResult(customer, card, businessId)
  },

  async redeemGoal(cardId: string, rewardId: string, redeemedBy: string): Promise<ScanResult> {
    const newCard = await LoyaltyRepository.redeemGoalAndReset(cardId, rewardId, redeemedBy)
    const customer = await CustomerRepository.findById(newCard.customer_id)
    if (!customer) throw new Error('Korisnik nije pronađen.')
    return buildReadyResult(customer, newCard, newCard.business_id)
  },

  async recordVisit(
    businessId: string,
    cardId: string,
    customerId: string,
    scannedBy: string,
    amountSpent?: number,
  ): Promise<number> {
    const card = await LoyaltyRepository.findCardById(cardId)
    if (!card) throw new Error('Kartica nije pronađena.')
    if (card.status === 'expired' || isDue(card.expires_at, card.status)) {
      throw new Error('Kartica je istekla i više ne prikuplja bodove.')
    }

    const program = await LoyaltyProgramRepository.findById(card.loyalty_program_id)
    const flatPoints = program?.points_per_visit ?? 0
    const amountPoints =
      amountSpent && program?.points_per_currency ? amountSpent * program.points_per_currency : 0
    const minimumSpendBonus =
      amountSpent && program?.minimum_spend_amount && amountSpent >= program.minimum_spend_amount
        ? (program.minimum_spend_bonus ?? 0)
        : 0
    const pointsEarned = flatPoints + amountPoints + minimumSpendBonus
    const balanceAfter = card.current_points + pointsEarned

    await LoyaltyRepository.insertPointTransaction({
      business_id: businessId,
      loyalty_card_id: cardId,
      customer_id: customerId,
      type: 'earn',
      points: pointsEarned,
      balance_after: balanceAfter,
      reference_type: 'visit',
      created_by: scannedBy,
    })

    await LoyaltyRepository.insertVisit({
      business_id: businessId,
      customer_id: customerId,
      loyalty_card_id: cardId,
      points_earned: pointsEarned,
      amount_spent: amountSpent ?? null,
      scanned_by: scannedBy,
    })

    return pointsEarned
  },
}
