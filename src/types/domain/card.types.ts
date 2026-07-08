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
  imageUrl: string | null
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
  minimumSpendAmount: number | null
  minimumSpendBonus: number | null
  expiryDays: number | null
  imageUrl: string | null
  isActive: boolean
}

export interface MyCard {
  id: string
  businessId: string
  businessName: string
  businessLogoUrl: string | null
  programId: string
  programName: string
  programImageUrl: string | null
  currentPoints: number
  cardNumber: string
  nextRewardThreshold: number | null
  qrCode: string
  isExpired: boolean
  expiresAt: string | null
}

export interface CardDetail extends MyCard {
  rewards: RewardOption[]
}
