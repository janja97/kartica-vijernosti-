import { useQuery, useQueryClient, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed } from 'vue'

import { businessService } from '@/services/business.service'
import { useAuthStore } from '@/stores/auth.store'
import type { Business } from '@/types/domain/business.types'

export function useCurrentBusiness(): UseQueryReturnType<Business | null, Error> {
  const auth = useAuthStore()
  const profileId = computed(() => auth.user?.id ?? null)

  return useQuery({
    queryKey: ['current-business', profileId],
    queryFn: async () => {
      if (!profileId.value) return null
      return businessService.getCurrentUserBusiness(profileId.value)
    },
    enabled: computed(() => profileId.value !== null),
  })
}

export function useInvalidateCurrentBusiness(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['current-business'] })
}
