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
]
