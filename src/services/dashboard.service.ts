import { CustomerRepository } from '@/repositories/CustomerRepository'
import { DashboardRepository } from '@/repositories/DashboardRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import type {
  ActivityItem,
  DashboardStats,
  TopCustomer,
  VisitsChartPoint,
} from '@/types/domain/dashboard.types'

const WEEKDAY_LABELS = ['Ned', 'Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub']

function startOfDayIsoDaysAgo(daysAgo: number): string {
  const date = new Date()
  date.setDate(date.getDate() - daysAgo)
  date.setHours(0, 0, 0, 0)
  return date.toISOString()
}

export const dashboardService = {
  async getStats(businessId: string): Promise<DashboardStats> {
    const [totalCustomers, activeCards, todayVisits, rewardsIssued, rewardsRedeemed] =
      await Promise.all([
        CustomerRepository.countByBusiness(businessId),
        LoyaltyRepository.countActiveCards(businessId),
        LoyaltyRepository.countVisitsSince(businessId, startOfDayIsoDaysAgo(0)),
        DashboardRepository.countRedemptions(businessId),
        DashboardRepository.countRedemptions(businessId, 'fulfilled'),
      ])

    return { totalCustomers, activeCards, todayVisits, rewardsIssued, rewardsRedeemed }
  },

  async getVisitsLast7Days(businessId: string): Promise<VisitsChartPoint[]> {
    return dashboardService.getVisitsChart(businessId, 7)
  },

  async getVisitsChart(businessId: string, days: number): Promise<VisitsChartPoint[]> {
    const visits = await LoyaltyRepository.visitsSince(businessId, startOfDayIsoDaysAgo(days - 1))

    const buckets = new Map<string, number>()
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date()
      date.setDate(date.getDate() - i)
      buckets.set(date.toDateString(), 0)
    }

    for (const visit of visits) {
      const day = new Date(visit.visited_at).toDateString()
      buckets.set(day, (buckets.get(day) ?? 0) + 1)
    }

    return Array.from(buckets.entries()).map(([dateString, visitCount]) => {
      const date = new Date(dateString)
      const label =
        days <= 7
          ? (WEEKDAY_LABELS[date.getDay()] ?? '')
          : `${String(date.getDate()).padStart(2, '0')}.${String(date.getMonth() + 1).padStart(2, '0')}.`
      return { label, visits: visitCount }
    })
  },

  async getTopCustomers(businessId: string, limit = 5): Promise<TopCustomer[]> {
    const cards = await LoyaltyRepository.topCardsByPoints(businessId, limit)
    if (cards.length === 0) return []

    const customerIds = cards.map((card) => card.customer_id)
    const [customers, visitCounts] = await Promise.all([
      CustomerRepository.findByIds(customerIds),
      LoyaltyRepository.countVisitsByCustomers(businessId, customerIds),
    ])
    const customerById = new Map(customers.map((customer) => [customer.id, customer]))

    return cards.map((card) => {
      const customer = customerById.get(card.customer_id)
      const name = customer
        ? `${customer.first_name} ${customer.last_name ?? ''}`.trim()
        : 'Nepoznat korisnik'
      return {
        id: card.customer_id,
        name,
        points: card.current_points,
        visits: visitCounts[card.customer_id] ?? 0,
      }
    })
  },

  async getRecentActivity(businessId: string, limit = 5): Promise<ActivityItem[]> {
    const logs = await DashboardRepository.recentActivity(businessId, limit)

    return logs.map((log) => ({
      id: log.id,
      action: log.action,
      description: log.description,
      createdAt: log.created_at,
    }))
  },
}
