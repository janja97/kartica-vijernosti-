import { useQuery, useQueryClient, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed, type ComputedRef } from 'vue'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { marketingService } from '@/services/marketing.service'
import type { BirthdayRewardConfig, PromoCode } from '@/types/domain/marketing.types'

function useBusinessId(): ComputedRef<string | null> {
  const { data: business } = useCurrentBusiness()
  return computed(() => business.value?.id ?? null)
}

const DEFAULT_BIRTHDAY_REWARD: BirthdayRewardConfig = {
  isEnabled: false,
  rewardType: 'discount',
  rewardAmount: null,
  daysBefore: 0,
  validDays: 7,
}

export function useBirthdayReward(): UseQueryReturnType<BirthdayRewardConfig, Error> & {
  businessId: () => string | null
} {
  const businessId = useBusinessId()

  const query = useQuery({
    queryKey: ['birthday-reward', businessId],
    queryFn: async () => {
      if (!businessId.value) return DEFAULT_BIRTHDAY_REWARD
      return marketingService.getBirthdayReward(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })

  return { ...query, businessId: () => businessId.value }
}

export function useInvalidateBirthdayReward(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['birthday-reward'] })
}

export function useReferralEnabled(): UseQueryReturnType<boolean, Error> & {
  businessId: () => string | null
} {
  const businessId = useBusinessId()

  const query = useQuery({
    queryKey: ['referral-enabled', businessId],
    queryFn: async () => {
      if (!businessId.value) return true
      return marketingService.getReferralEnabled(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })

  return { ...query, businessId: () => businessId.value }
}

export function useInvalidateReferralEnabled(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['referral-enabled'] })
}

export function usePromoCodes(): UseQueryReturnType<PromoCode[], Error> & {
  businessId: () => string | null
} {
  const businessId = useBusinessId()

  const query = useQuery({
    queryKey: ['promo-codes', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return marketingService.listPromoCodes(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })

  return { ...query, businessId: () => businessId.value }
}

export function useInvalidatePromoCodes(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['promo-codes'] })
}
