import { useQuery, useQueryClient, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed } from 'vue'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { rewardService } from '@/services/reward.service'
import type { PendingRedemption, RewardCatalogItem } from '@/types/domain/reward.types'

export function useRewards(): UseQueryReturnType<RewardCatalogItem[], Error> & {
  businessId: () => string | null
} {
  const { data: business } = useCurrentBusiness()
  const businessId = computed(() => business.value?.id ?? null)

  const query = useQuery({
    queryKey: ['rewards', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return rewardService.list(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })

  return { ...query, businessId: () => businessId.value }
}

export function usePendingRedemptions(): UseQueryReturnType<PendingRedemption[], Error> {
  const { data: business } = useCurrentBusiness()
  const businessId = computed(() => business.value?.id ?? null)

  return useQuery({
    queryKey: ['pending-redemptions', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return rewardService.listPendingRedemptions(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}

export function useInvalidateRewards(): () => Promise<void> {
  const queryClient = useQueryClient()
  return async () => {
    await queryClient.invalidateQueries({ queryKey: ['rewards'] })
    await queryClient.invalidateQueries({ queryKey: ['pending-redemptions'] })
  }
}
