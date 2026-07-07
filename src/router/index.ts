import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

import { setupRouterGuards } from '@/router/guards'
import { authRoutes } from '@/router/routes/auth.routes'
import { dashboardRoutes } from '@/router/routes/dashboard.routes'
import { portalRoutes } from '@/router/routes/portal.routes'
import { publicRoutes } from '@/router/routes/public.routes'

const notFoundRoute: RouteRecordRaw = {
  path: '/:pathMatch(.*)*',
  name: 'not-found',
  component: () => import('@/pages/not-found/NotFoundPage.vue'),
}

export const router = createRouter({
  history: createWebHistory(),
  routes: [...publicRoutes, ...authRoutes, ...dashboardRoutes, ...portalRoutes, notFoundRoute],
  scrollBehavior() {
    return { top: 0 }
  },
})

setupRouterGuards(router)
