import type { BirthdayRewardType } from '@/types/database.types'

export interface BirthdayRewardConfig {
  isEnabled: boolean
  rewardType: BirthdayRewardType
  rewardAmount: number | null
  daysBefore: number
  validDays: number
}

export interface PromoCode {
  id: string
  businessId: string
  code: string
  description: string | null
  discountPercent: number | null
  discountAmount: number | null
  maxRedemptions: number | null
  timesRedeemed: number
  isActive: boolean
  expiresAt: string | null
}

export interface PromoCodeInput {
  code: string
  description: string | null
  discountPercent: number | null
  discountAmount: number | null
  maxRedemptions: number | null
  expiresAt: string | null
}
