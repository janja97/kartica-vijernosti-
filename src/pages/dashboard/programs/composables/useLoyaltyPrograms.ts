import { useQuery, useQueryClient, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed } from 'vue'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { loyaltyProgramService } from '@/services/loyaltyProgram.service'
import type { LoyaltyProgram } from '@/types/domain/card.types'

export function useLoyaltyPrograms(): UseQueryReturnType<LoyaltyProgram[], Error> & {
  businessId: () => string | null
} {
  const { data: business } = useCurrentBusiness()
  const businessId = computed(() => business.value?.id ?? null)

  const query = useQuery({
    queryKey: ['loyalty-programs', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return loyaltyProgramService.list(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })

  return { ...query, businessId: () => businessId.value }
}

export function useInvalidateLoyaltyPrograms(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['loyalty-programs'] })
}
