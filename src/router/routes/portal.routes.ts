import type { RouteRecordRaw } from 'vue-router'

export const portalRoutes: RouteRecordRaw[] = [
  {
    path: '/app',
    component: () => import('@/layouts/PortalLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'portal-my-cards',
        component: () => import('@/pages/portal/my-cards/MyCardsPage.vue'),
      },
      {
        path: 'businesses',
        name: 'portal-businesses',
        component: () => import('@/pages/portal/directory/BusinessDirectoryPage.vue'),
      },
      {
        path: 'businesses/:businessId',
        name: 'portal-business-detail',
        component: () => import('@/pages/portal/business-detail/BusinessDetailPage.vue'),
        props: true,
      },
      {
        path: 'cards/:cardId',
        name: 'portal-card-detail',
        component: () => import('@/pages/portal/card-detail/CardDetailPage.vue'),
        props: true,
      },
    ],
  },
]
