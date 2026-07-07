import type { RouteRecordRaw } from 'vue-router'

export const dashboardRoutes: RouteRecordRaw[] = [
  {
    path: '/dashboard',
    component: () => import('@/layouts/DashboardLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'dashboard-overview',
        component: () => import('@/pages/dashboard/DashboardPage.vue'),
      },
      {
        path: 'customers',
        name: 'dashboard-customers',
        component: () => import('@/pages/dashboard/customers/CustomersPage.vue'),
      },
      {
        path: 'programs',
        name: 'dashboard-programs',
        component: () => import('@/pages/dashboard/programs/ProgramsPage.vue'),
      },
      {
        path: 'rewards',
        name: 'dashboard-rewards',
        component: () => import('@/pages/dashboard/rewards/RewardsPage.vue'),
      },
      {
        path: 'scan',
        name: 'dashboard-scan',
        component: () => import('@/pages/dashboard/scan/ScanPage.vue'),
      },
      {
        path: 'marketing',
        name: 'dashboard-marketing',
        component: () => import('@/pages/dashboard/marketing/MarketingPage.vue'),
      },
      {
        path: 'analytics',
        name: 'dashboard-analytics',
        component: () => import('@/pages/dashboard/analytics/AnalyticsPage.vue'),
      },
      {
        path: 'settings',
        name: 'dashboard-settings',
        component: () => import('@/pages/dashboard/settings/SettingsPage.vue'),
      },
    ],
  },
]
