import { useQuery, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed } from 'vue'

import { customerPortalService } from '@/services/customerPortal.service'
import { useAuthStore } from '@/stores/auth.store'
import type { MyCard } from '@/types/domain/card.types'

export function useMyCards(): UseQueryReturnType<MyCard[], Error> {
  const auth = useAuthStore()
  const profileId = computed(() => auth.user?.id ?? null)

  return useQuery({
    queryKey: ['my-cards', profileId],
    queryFn: async () => {
      if (!profileId.value) return []
      return customerPortalService.getMyCards(profileId.value)
    },
    enabled: computed(() => profileId.value !== null),
  })
}
