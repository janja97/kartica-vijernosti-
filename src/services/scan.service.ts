import { CustomerRepository } from '@/repositories/CustomerRepository'
import { LoyaltyProgramRepository } from '@/repositories/LoyaltyProgramRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import { QrCodeRepository } from '@/repositories/QrCodeRepository'
import { RewardRedemptionRepository } from '@/repositories/RewardRedemptionRepository'
import { RewardRepository } from '@/repositories/RewardRepository'

export interface PendingRedemptionSummary {
  id: string
  rewardName: string
  pointsSpent: number
}

export interface ScanResult {
  customerId: string
  customerName: string
  cardId: string
  programName: string
  currentPoints: number
  nextRewardThreshold: number | null
  pendingRedemptions: PendingRedemptionSummary[]
}

export const scanService = {
  async lookupByCode(code: string, businessId: string): Promise<ScanResult> {
    const qrCode = await QrCodeRepository.findByCode(code, businessId)
    if (!qrCode) throw new Error('QR kod nije prepoznat za ovu tvrtku.')

    const customer = await CustomerRepository.findById(qrCode.customer_id)
    if (!customer) throw new Error('Korisnik nije pronađen.')

    const cards = await LoyaltyRepository.findCardsForCustomers([customer.id])
    const card = cards.find((c) => c.business_id === businessId)
    if (!card) throw new Error('Ovaj korisnik nema karticu kod ove tvrtke.')

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

    return {
      customerId: customer.id,
      customerName: `${customer.first_name} ${customer.last_name ?? ''}`.trim(),
      cardId: card.id,
      programName: program?.name ?? '',
      currentPoints: card.current_points,
      nextRewardThreshold,
      pendingRedemptions: pending.map((redemption) => ({
        id: redemption.id,
        rewardName: rewardById.get(redemption.reward_id)?.name ?? 'Nagrada',
        pointsSpent: redemption.points_spent,
      })),
    }
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

    const program = await LoyaltyProgramRepository.findById(card.loyalty_program_id)
    const flatPoints = program?.points_per_visit ?? 0
    const amountPoints =
      amountSpent && program?.points_per_currency ? amountSpent * program.points_per_currency : 0
    const pointsEarned = flatPoints + amountPoints
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
