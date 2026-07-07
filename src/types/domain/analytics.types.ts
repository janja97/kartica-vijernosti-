import type { LoyaltyProgramType } from '@/types/database.types'

export interface AnalyticsSummary {
  pointsEarned: number
  pointsRedeemed: number
  newCustomers: number
}

export interface ProgramPerformance {
  id: string
  name: string
  type: LoyaltyProgramType
  activeCards: number
  pointsBalance: number
}
