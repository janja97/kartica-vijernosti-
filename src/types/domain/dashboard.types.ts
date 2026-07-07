export interface DashboardStats {
  totalCustomers: number
  activeCards: number
  todayVisits: number
  rewardsIssued: number
  rewardsRedeemed: number
}

export interface VisitsChartPoint {
  label: string
  visits: number
}

export interface TopCustomer {
  id: string
  name: string
  points: number
  visits: number
}

export interface ActivityItem {
  id: string
  action: string
  description: string | null
  createdAt: string
}
