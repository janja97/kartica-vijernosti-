<script setup lang="ts">
import {
  ChartPieIcon,
  Cog6ToothIcon,
  GiftIcon,
  HomeIcon,
  MegaphoneIcon,
  QrCodeIcon,
  SparklesIcon,
  UsersIcon,
  XMarkIcon,
} from '@heroicons/vue/24/outline'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRoute } from 'vue-router'

import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { useUiStore } from '@/stores/ui.store'

interface NavItem {
  labelKey: string
  icon: typeof HomeIcon
  to?: string
}

const { t } = useI18n()
const route = useRoute()
const ui = useUiStore()
const { data: business, isLoading } = useCurrentBusiness()

const navItems: NavItem[] = [
  { labelKey: 'dashboard.nav.overview', icon: HomeIcon, to: '/dashboard' },
  { labelKey: 'dashboard.nav.scan', icon: QrCodeIcon, to: '/dashboard/scan' },
  { labelKey: 'dashboard.nav.customers', icon: UsersIcon, to: '/dashboard/customers' },
  { labelKey: 'dashboard.nav.programs', icon: SparklesIcon, to: '/dashboard/programs' },
  { labelKey: 'dashboard.nav.rewards', icon: GiftIcon, to: '/dashboard/rewards' },
  { labelKey: 'dashboard.nav.marketing', icon: MegaphoneIcon, to: '/dashboard/marketing' },
  { labelKey: 'dashboard.nav.analytics', icon: ChartPieIcon, to: '/dashboard/analytics' },
  { labelKey: 'dashboard.nav.settings', icon: Cog6ToothIcon, to: '/dashboard/settings' },
]

const initials = computed(() => {
  const name = business.value?.name ?? ''
  return (
    name
      .split(' ')
      .map((part) => part[0])
      .join('')
      .slice(0, 2)
      .toUpperCase() || '?'
  )
})

const roleLabel = computed(() => {
  const role = business.value?.currentUserRole
  return role ? t(`dashboard.roles.${role}`) : ''
})
</script>

<template>
  <Transition
    enter-active-class="transition duration-200 ease-out"
    enter-from-class="opacity-0"
    enter-to-class="opacity-100"
    leave-active-class="transition duration-150 ease-in"
    leave-from-class="opacity-100"
    leave-to-class="opacity-0"
  >
    <div
      v-if="ui.isMobileSidebarOpen"
      class="fixed inset-0 z-40 bg-slate-950/50 lg:hidden"
      @click="ui.closeMobileSidebar()"
    />
  </Transition>

  <aside
    class="fixed inset-y-0 left-0 z-50 flex w-64 flex-none flex-col border-r border-border bg-surface-raised transition-transform duration-200 lg:static lg:z-auto lg:translate-x-0 lg:bg-surface-raised/60"
    :class="ui.isMobileSidebarOpen ? 'translate-x-0' : '-translate-x-full'"
  >
    <div
      class="flex h-16 items-center justify-between gap-2 px-6 font-display font-semibold tracking-tight"
    >
      <div class="flex items-center gap-2">
        <span
          class="flex h-7 w-7 items-center justify-center rounded-lg bg-gradient-to-br from-brand-600 to-accent-500 text-sm text-white"
        >
          L
        </span>
        LoyalFlow
      </div>
      <button
        type="button"
        class="rounded-lg p-1 text-slate-400 hover:text-slate-900 dark:hover:text-white lg:hidden"
        aria-label="Close menu"
        @click="ui.closeMobileSidebar()"
      >
        <XMarkIcon class="h-5 w-5" />
      </button>
    </div>

    <nav class="flex-1 space-y-1 px-3 py-4">
      <template v-for="item in navItems" :key="item.labelKey">
        <RouterLink
          v-if="item.to"
          :to="item.to"
          class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors"
          :class="
            route.path === item.to
              ? 'bg-brand-50 text-brand-700 dark:bg-brand-500/10 dark:text-brand-400'
              : 'text-slate-600 hover:bg-surface-sunken hover:text-slate-900 dark:text-slate-300 dark:hover:text-white'
          "
          @click="ui.closeMobileSidebar()"
        >
          <component :is="item.icon" class="h-5 w-5" />
          {{ t(item.labelKey) }}
        </RouterLink>

        <div
          v-else
          class="flex cursor-default items-center justify-between rounded-lg px-3 py-2.5 text-sm font-medium text-slate-400 dark:text-slate-600"
        >
          <span class="flex items-center gap-3">
            <component :is="item.icon" class="h-5 w-5" />
            {{ t(item.labelKey) }}
          </span>
          <span
            class="rounded-full bg-surface-sunken px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-slate-400 dark:text-slate-500"
          >
            {{ t('dashboard.nav.soon') }}
          </span>
        </div>
      </template>
    </nav>

    <div class="border-t border-border p-4">
      <div
        v-if="isLoading"
        class="flex items-center gap-3 rounded-lg bg-surface-sunken px-3 py-2.5"
      >
        <div class="h-9 w-9 flex-none animate-pulse rounded-full bg-surface" />
        <div class="min-w-0 flex-1 space-y-1.5">
          <div class="h-3 w-24 animate-pulse rounded bg-surface" />
          <div class="h-2.5 w-14 animate-pulse rounded bg-surface" />
        </div>
      </div>

      <div v-else class="flex items-center gap-3 rounded-lg bg-surface-sunken px-3 py-2.5">
        <span
          class="flex h-9 w-9 flex-none items-center justify-center rounded-full bg-brand-600 text-sm font-semibold text-white"
        >
          {{ initials }}
        </span>
        <div class="min-w-0">
          <p class="truncate text-sm font-medium text-slate-900 dark:text-white">
            {{ business?.name }}
          </p>
          <p class="truncate text-xs text-slate-500 dark:text-slate-400">{{ roleLabel }}</p>
        </div>
      </div>
    </div>
  </aside>
</template>
