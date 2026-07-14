import type { RouteRecordRaw } from 'vue-router'

export const publicRoutes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/layouts/LandingLayout.vue'),
    children: [
      {
        path: '',
        name: 'landing',
        component: () => import('@/pages/landing/LandingPage.vue'),
      },
    ],
  },
  {
    path: '/my-card',
    component: () => import('@/layouts/AuthLayout.vue'),
    children: [
      {
        path: '',
        name: 'customer-entry',
        component: () => import('@/pages/customer/CustomerEntryPage.vue'),
      },
    ],
  },
]
