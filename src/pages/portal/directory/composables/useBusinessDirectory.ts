import { useQuery, type UseQueryReturnType } from '@tanstack/vue-query'
import { type MaybeRefOrGetter, toValue } from 'vue'

import type { BusinessDirectoryFilters } from '@/repositories/BusinessRepository'
import { customerPortalService } from '@/services/customerPortal.service'
import type { BusinessDirectoryItem } from '@/types/domain/card.types'

export function useBusinessDirectory(
  filters: MaybeRefOrGetter<BusinessDirectoryFilters>,
): UseQueryReturnType<BusinessDirectoryItem[], Error> {
  return useQuery({
    queryKey: ['business-directory', filters],
    queryFn: () => customerPortalService.listBusinessDirectory(toValue(filters)),
  })
}
