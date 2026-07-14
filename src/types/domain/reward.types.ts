import type { RewardType } from '@/types/database.types'

export interface RewardCatalogItem {
  id: string
  businessId: string
  loyaltyProgramId: string | null
  name: string
  description: string | null
  type: RewardType
  pointsCost: number | null
  discountPercent: number | null
  isActive: boolean
  isGoal: boolean
}

export interface RewardOption extends RewardCatalogItem {
  affordable: boolean
}

export interface PendingRedemption {
  id: string
  cardId: string
  customerId: string
  customerName: string
  rewardId: string
  rewardName: string
  pointsSpent: number
  createdAt: string
}
