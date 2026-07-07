import { AnalyticsRepository } from '@/repositories/AnalyticsRepository'
import { LoyaltyProgramRepository } from '@/repositories/LoyaltyProgramRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import type { AnalyticsSummary, ProgramPerformance } from '@/types/domain/analytics.types'

const EARN_TYPES = new Set(['earn', 'referral_bonus', 'birthday_bonus'])

function startOfDayIsoDaysAgo(daysAgo: number): string {
  const date = new Date()
  date.setDate(date.getDate() - daysAgo)
  date.setHours(0, 0, 0, 0)
  return date.toISOString()
}

export const analyticsService = {
  async getSummary(businessId: string): Promise<AnalyticsSummary> {
    const [transactions, newCustomers] = await Promise.all([
      AnalyticsRepository.listPointTransactions(businessId),
      AnalyticsRepository.countCustomersSince(businessId, startOfDayIsoDaysAgo(29)),
    ])

    let pointsEarned = 0
    let pointsRedeemed = 0
    for (const transaction of transactions) {
      if (EARN_TYPES.has(transaction.type)) {
        pointsEarned += transaction.points
      } else if (transaction.type === 'redeem') {
        pointsRedeemed += Math.abs(transaction.points)
      }
    }

    return { pointsEarned, pointsRedeemed, newCustomers }
  },

  async getProgramPerformance(businessId: string): Promise<ProgramPerformance[]> {
    const [programs, cards] = await Promise.all([
      LoyaltyProgramRepository.listForBusiness(businessId),
      LoyaltyRepository.listCardsForBusiness(businessId),
    ])

    return programs.map((program) => {
      const programCards = cards.filter((card) => card.loyalty_program_id === program.id)
      return {
        id: program.id,
        name: program.name,
        type: program.type,
        activeCards: programCards.filter((card) => card.status === 'active').length,
        pointsBalance: programCards.reduce((sum, card) => sum + card.current_points, 0),
      }
    })
  },
}
