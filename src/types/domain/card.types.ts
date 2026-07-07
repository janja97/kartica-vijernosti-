import type { BusinessCategory, LoyaltyProgramType } from '@/types/database.types'
import type { RewardOption } from '@/types/domain/reward.types'

export interface BusinessDirectoryItem {
  id: string
  name: string
  slug: string
  category: BusinessCategory
  city: string | null
  description: string | null
}

export interface LoyaltyProgramSummary {
  id: string
  businessId: string
  name: string
  description: string | null
  type: LoyaltyProgramType
  color: string
  pointsPerVisit: number | null
}

export interface BusinessDetail extends BusinessDirectoryItem {
  programs: LoyaltyProgramSummary[]
}

export interface LoyaltyProgram {
  id: string
  businessId: string
  name: string
  description: string | null
  type: LoyaltyProgramType
  color: string
  pointsPerVisit: number | null
  isActive: boolean
}

export interface MyCard {
  id: string
  businessId: string
  businessName: string
  programId: string
  programName: string
  currentPoints: number
  cardNumber: string
  nextRewardThreshold: number | null
  qrCode: string
}

export interface CardDetail extends MyCard {
  rewards: RewardOption[]
}
