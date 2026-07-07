import { useQuery, type UseQueryReturnType } from '@tanstack/vue-query'
import { type MaybeRefOrGetter, toValue } from 'vue'

import { customerPortalService } from '@/services/customerPortal.service'
import type { BusinessDetail } from '@/types/domain/card.types'

export function useBusinessDetail(
  businessId: MaybeRefOrGetter<string>,
): UseQueryReturnType<BusinessDetail | null, Error> {
  return useQuery({
    queryKey: ['business-detail', businessId],
    queryFn: () => customerPortalService.getBusinessDetail(toValue(businessId)),
  })
}
