import { BirthdayRewardRepository } from '@/repositories/BirthdayRewardRepository'
import { BusinessSettingsRepository } from '@/repositories/BusinessSettingsRepository'
import { PromoCodeRepository } from '@/repositories/PromoCodeRepository'
import type { Json } from '@/types/database.types'
import type {
  BirthdayRewardConfig,
  PromoCode,
  PromoCodeInput,
} from '@/types/domain/marketing.types'

const DEFAULT_BIRTHDAY_REWARD: BirthdayRewardConfig = {
  isEnabled: false,
  rewardType: 'discount',
  rewardAmount: null,
  daysBefore: 0,
  validDays: 7,
}

function readRewardAmount(value: Json): number | null {
  if (value && typeof value === 'object' && !Array.isArray(value) && 'amount' in value) {
    const amount = value.amount
    return typeof amount === 'number' ? amount : null
  }
  return null
}

function toPromoCode(row: {
  id: string
  business_id: string
  code: string
  description: string | null
  discount_percent: number | null
  discount_amount: number | null
  max_redemptions: number | null
  times_redeemed: number
  is_active: boolean
  expires_at: string | null
}): PromoCode {
  return {
    id: row.id,
    businessId: row.business_id,
    code: row.code,
    description: row.description,
    discountPercent: row.discount_percent,
    discountAmount: row.discount_amount,
    maxRedemptions: row.max_redemptions,
    timesRedeemed: row.times_redeemed,
    isActive: row.is_active,
    expiresAt: row.expires_at,
  }
}

export const marketingService = {
  async getBirthdayReward(businessId: string): Promise<BirthdayRewardConfig> {
    const row = await BirthdayRewardRepository.findByBusiness(businessId)
    if (!row) return DEFAULT_BIRTHDAY_REWARD

    return {
      isEnabled: row.is_enabled,
      rewardType: row.reward_type,
      rewardAmount: readRewardAmount(row.reward_value),
      daysBefore: row.days_before,
      validDays: row.valid_days,
    }
  },

  async saveBirthdayReward(businessId: string, input: BirthdayRewardConfig): Promise<void> {
    await BirthdayRewardRepository.upsert({
      business_id: businessId,
      is_enabled: input.isEnabled,
      reward_type: input.rewardType,
      reward_value: input.rewardAmount === null ? {} : { amount: input.rewardAmount },
      days_before: input.daysBefore,
      valid_days: input.validDays,
    })
  },

  async getReferralEnabled(businessId: string): Promise<boolean> {
    const settings = await BusinessSettingsRepository.findByBusiness(businessId)
    return settings?.referral_program_enabled ?? true
  },

  async setReferralEnabled(businessId: string, enabled: boolean): Promise<void> {
    await BusinessSettingsRepository.update(businessId, { referral_program_enabled: enabled })
  },

  async listPromoCodes(businessId: string): Promise<PromoCode[]> {
    const rows = await PromoCodeRepository.listForBusiness(businessId)
    return rows.map(toPromoCode)
  },

  async createPromoCode(businessId: string, input: PromoCodeInput): Promise<PromoCode> {
    const row = await PromoCodeRepository.create({
      business_id: businessId,
      code: input.code,
      description: input.description,
      discount_percent: input.discountPercent,
      discount_amount: input.discountAmount,
      max_redemptions: input.maxRedemptions,
      expires_at: input.expiresAt,
    })
    return toPromoCode(row)
  },

  async setPromoCodeActive(id: string, isActive: boolean): Promise<void> {
    await PromoCodeRepository.update(id, { is_active: isActive })
  },
}
