import { useQuery, useQueryClient, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed } from 'vue'

import { profileService } from '@/services/profile.service'
import { useAuthStore } from '@/stores/auth.store'
import type { Profile } from '@/types/domain/profile.types'

export function useProfile(): UseQueryReturnType<Profile | null, Error> {
  const auth = useAuthStore()
  const profileId = computed(() => auth.user?.id ?? null)

  return useQuery({
    queryKey: ['current-profile', profileId],
    queryFn: async () => {
      if (!profileId.value) return null
      return profileService.getProfile(profileId.value)
    },
    enabled: computed(() => profileId.value !== null),
  })
}

export function useInvalidateProfile(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['current-profile'] })
}
