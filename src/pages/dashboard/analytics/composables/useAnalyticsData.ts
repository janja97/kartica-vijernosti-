import { useQuery, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed, type ComputedRef } from 'vue'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { analyticsService } from '@/services/analytics.service'
import { dashboardService } from '@/services/dashboard.service'
import type { AnalyticsSummary, ProgramPerformance } from '@/types/domain/analytics.types'
import type { VisitsChartPoint } from '@/types/domain/dashboard.types'

function useBusinessId(): ComputedRef<string | null> {
  const { data: business } = useCurrentBusiness()
  return computed(() => business.value?.id ?? null)
}

const EMPTY_SUMMARY: AnalyticsSummary = { pointsEarned: 0, pointsRedeemed: 0, newCustomers: 0 }

export function useAnalyticsSummary(): UseQueryReturnType<AnalyticsSummary, Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['analytics-summary', businessId],
    queryFn: async () => {
      if (!businessId.value) return EMPTY_SUMMARY
      return analyticsService.getSummary(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}

export function useVisitsChart30Days(): UseQueryReturnType<VisitsChartPoint[], Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['analytics-visits-chart', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return dashboardService.getVisitsChart(businessId.value, 30)
    },
    enabled: computed(() => businessId.value !== null),
  })
}

export function useProgramPerformance(): UseQueryReturnType<ProgramPerformance[], Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['analytics-program-performance', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return analyticsService.getProgramPerformance(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}
