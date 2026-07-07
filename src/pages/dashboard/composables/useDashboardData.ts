import { useQuery, type UseQueryReturnType } from '@tanstack/vue-query'
import { computed, type ComputedRef } from 'vue'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { dashboardService } from '@/services/dashboard.service'
import type {
  ActivityItem,
  DashboardStats,
  TopCustomer,
  VisitsChartPoint,
} from '@/types/domain/dashboard.types'

function useBusinessId(): ComputedRef<string | null> {
  const { data: business } = useCurrentBusiness()
  return computed(() => business.value?.id ?? null)
}

const EMPTY_STATS: DashboardStats = {
  totalCustomers: 0,
  activeCards: 0,
  todayVisits: 0,
  rewardsIssued: 0,
  rewardsRedeemed: 0,
}

export function useDashboardStats(): UseQueryReturnType<DashboardStats, Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['dashboard-stats', businessId],
    queryFn: async () => {
      if (!businessId.value) return EMPTY_STATS
      return dashboardService.getStats(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}

export function useVisitsChart(): UseQueryReturnType<VisitsChartPoint[], Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['dashboard-visits-chart', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return dashboardService.getVisitsLast7Days(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}

export function useTopCustomers(): UseQueryReturnType<TopCustomer[], Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['dashboard-top-customers', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return dashboardService.getTopCustomers(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}

export function useRecentActivity(): UseQueryReturnType<ActivityItem[], Error> {
  const businessId = useBusinessId()

  return useQuery({
    queryKey: ['dashboard-recent-activity', businessId],
    queryFn: async () => {
      if (!businessId.value) return []
      return dashboardService.getRecentActivity(businessId.value)
    },
    enabled: computed(() => businessId.value !== null),
  })
}
