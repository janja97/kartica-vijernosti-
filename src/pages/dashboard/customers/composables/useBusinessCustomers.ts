import { useQuery, useQueryClient, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed } from 'vue'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { customerService } from '@/services/customer.service'
import type { BusinessCustomer } from '@/types/domain/customer.types'

export function useBusinessCustomers(): UseQueryReturnType<BusinessCustomer[], Error> & {
  businessId: () => string | null
} {
  const { data: business } = useCurrentBusiness()
  const businessId = computed(() => business.value?.id ?? null)

  const query = useQuery({
    queryKey: ['business-customers', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return customerService.listForBusiness(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })

  return { ...query, businessId: () => businessId.value }
}

export function useInvalidateBusinessCustomers(): () => Promise<void> {
  const queryClient = useQueryClient()
  return () => queryClient.invalidateQueries({ queryKey: ['business-customers'] })
}
