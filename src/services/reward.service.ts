import { CustomerRepository } from '@/repositories/CustomerRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import { RewardRedemptionRepository } from '@/repositories/RewardRedemptionRepository'
import { RewardRepository } from '@/repositories/RewardRepository'
import type { Database } from '@/types/database.types'
import type { PendingRedemption, RewardCatalogItem } from '@/types/domain/reward.types'

type RewardCatalogRow = Database['public']['Tables']['reward_catalog']['Row']

function toDomain(row: RewardCatalogRow): RewardCatalogItem {
  return {
    id: row.id,
    businessId: row.business_id,
    loyaltyProgramId: row.loyalty_program_id,
    name: row.name,
    description: row.description,
    type: row.type,
    pointsCost: row.points_cost,
    isActive: row.is_active,
  }
}

export interface RewardInput {
  name: string
  description: string | null
  pointsCost: number
  isActive?: boolean
}

export const rewardService = {
  async list(businessId: string): Promise<RewardCatalogItem[]> {
    const rows = await RewardRepository.listForBusiness(businessId)
    return rows.map(toDomain)
  },

  async create(businessId: string, input: RewardInput): Promise<RewardCatalogItem> {
    const row = await RewardRepository.create({
      business_id: businessId,
      name: input.name,
      description: input.description,
      type: 'discount',
      points_cost: input.pointsCost,
    })
    return toDomain(row)
  },

  async update(id: string, input: Partial<RewardInput>): Promise<RewardCatalogItem> {
    const row = await RewardRepository.update(id, {
      name: input.name,
      description: input.description,
      points_cost: input.pointsCost,
      is_active: input.isActive,
    })
    return toDomain(row)
  },

  async listPendingRedemptions(businessId: string): Promise<PendingRedemption[]> {
    const pending = await RewardRedemptionRepository.listPendingForBusiness(businessId)
    if (pending.length === 0) return []

    const [customers, rewards] = await Promise.all([
      CustomerRepository.findByIds(pending.map((redemption) => redemption.customer_id)),
      RewardRepository.findByIds(pending.map((redemption) => redemption.reward_id)),
    ])
    const customerById = new Map(customers.map((customer) => [customer.id, customer]))
    const rewardById = new Map(rewards.map((reward) => [reward.id, reward]))

    return pending
      .filter((redemption) => redemption.loyalty_card_id !== null)
      .map((redemption) => {
        const customer = customerById.get(redemption.customer_id)
        return {
          id: redemption.id,
          cardId: redemption.loyalty_card_id as string,
          customerId: redemption.customer_id,
          customerName: customer
            ? `${customer.first_name} ${customer.last_name ?? ''}`.trim()
            : 'Nepoznat korisnik',
          rewardId: redemption.reward_id,
          rewardName: rewardById.get(redemption.reward_id)?.name ?? 'Nagrada',
          pointsSpent: redemption.points_spent,
          createdAt: redemption.created_at,
        }
      })
  },

  async fulfillRedemption(
    redemptionId: string,
    cardId: string,
    businessId: string,
    customerId: string,
  ): Promise<void> {
    const redemption = await RewardRedemptionRepository.fulfill(redemptionId)

    const card = await LoyaltyRepository.findCardById(cardId)
    if (!card) return

    const balanceAfter = card.current_points - redemption.points_spent
    await LoyaltyRepository.insertPointTransaction({
      business_id: businessId,
      loyalty_card_id: cardId,
      customer_id: customerId,
      type: 'redeem',
      points: -redemption.points_spent,
      balance_after: balanceAfter,
      reference_type: 'redemption',
      reference_id: redemptionId,
    })
  },
}
