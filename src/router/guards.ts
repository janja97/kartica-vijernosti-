import type { Router } from 'vue-router'

import { useAuthStore } from '@/stores/auth.store'

export function setupRouterGuards(router: Router): void {
  router.beforeEach(async (to) => {
    const auth = useAuthStore()
    if (!auth.isReady) {
      await auth.initialize()
    }

    if (to.meta.requiresAuth && !auth.isAuthenticated) {
      return { name: 'auth-login' }
    }

    if (to.meta.guestOnly && auth.isAuthenticated) {
      return { name: 'dashboard-overview' }
    }

    return true
  })

  router.afterEach((to) => {
    document.title = to.name ? `LoyalFlow · ${String(to.name)}` : 'LoyalFlow'
  })
}
