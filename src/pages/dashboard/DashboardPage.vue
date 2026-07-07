<script setup lang="ts">
import {
  CalendarDaysIcon,
  CheckBadgeIcon,
  CreditCardIcon,
  GiftIcon,
  UsersIcon,
} from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import ActivityFeed from '@/pages/dashboard/components/ActivityFeed.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import StatCard from '@/pages/dashboard/components/StatCard.vue'
import TopCustomersList from '@/pages/dashboard/components/TopCustomersList.vue'
import VisitsChart from '@/pages/dashboard/components/VisitsChart.vue'
import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import {
  useDashboardStats,
  useRecentActivity,
  useTopCustomers,
  useVisitsChart,
} from '@/pages/dashboard/composables/useDashboardData'

const { t } = useI18n()

const { data: business } = useCurrentBusiness()
const { data: stats, isLoading: isStatsLoading } = useDashboardStats()
const { data: chartPoints, isLoading: isChartLoading } = useVisitsChart()
const { data: topCustomers, isLoading: isTopCustomersLoading } = useTopCustomers()
const { data: activity, isLoading: isActivityLoading } = useRecentActivity()

const statCards = [
  { key: 'totalCustomers', labelKey: 'dashboard.stats.totalCustomers', icon: UsersIcon },
  { key: 'activeCards', labelKey: 'dashboard.stats.activeCards', icon: CreditCardIcon },
  { key: 'todayVisits', labelKey: 'dashboard.stats.todayVisits', icon: CalendarDaysIcon },
  { key: 'rewardsIssued', labelKey: 'dashboard.stats.rewardsIssued', icon: GiftIcon },
  { key: 'rewardsRedeemed', labelKey: 'dashboard.stats.rewardsRedeemed', icon: CheckBadgeIcon },
] as const
</script>

<template>
  <DashboardTopbar :title="t('dashboard.overview.title')" />

  <main class="flex-1 space-y-6 p-6">
    <div>
      <h2 class="text-sm text-slate-500 dark:text-slate-400">
        {{ t('dashboard.overview.welcomeBack') }}
        <span class="font-medium text-slate-700 dark:text-slate-200">{{ business?.name }}</span>
      </h2>
    </div>

    <div class="grid grid-cols-2 gap-4 lg:grid-cols-5">
      <template v-if="isStatsLoading">
        <div v-for="n in 5" :key="n" class="rounded-2xl border border-border bg-surface-raised p-5">
          <div class="h-3.5 w-24 animate-pulse rounded bg-surface-sunken" />
          <div class="mt-3 h-7 w-14 animate-pulse rounded bg-surface-sunken" />
        </div>
      </template>
      <StatCard
        v-for="card in statCards"
        v-else
        :key="card.key"
        :label="t(card.labelKey)"
        :value="stats?.[card.key] ?? 0"
        :icon="card.icon"
      />
    </div>

    <div class="grid gap-6 lg:grid-cols-3">
      <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft lg:col-span-2">
        <h3 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
          {{ t('dashboard.chart.title') }}
        </h3>
        <div class="mt-4">
          <div v-if="isChartLoading" class="h-64 animate-pulse rounded-lg bg-surface-sunken" />
          <VisitsChart
            v-else
            :labels="(chartPoints ?? []).map((point) => point.label)"
            :values="(chartPoints ?? []).map((point) => point.visits)"
          />
        </div>
      </div>

      <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft">
        <h3 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
          {{ t('dashboard.topCustomers.title') }}
        </h3>
        <div class="mt-4">
          <div v-if="isTopCustomersLoading" class="space-y-3">
            <div v-for="n in 5" :key="n" class="h-9 animate-pulse rounded-lg bg-surface-sunken" />
          </div>
          <p
            v-else-if="!topCustomers || topCustomers.length === 0"
            class="text-sm text-slate-500 dark:text-slate-400"
          >
            {{ t('dashboard.topCustomers.empty') }}
          </p>
          <TopCustomersList v-else :customers="topCustomers" />
        </div>
      </div>
    </div>

    <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft">
      <h3 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.activity.title') }}
      </h3>
      <div class="mt-4">
        <div v-if="isActivityLoading" class="space-y-3">
          <div v-for="n in 4" :key="n" class="h-10 animate-pulse rounded-lg bg-surface-sunken" />
        </div>
        <p
          v-else-if="!activity || activity.length === 0"
          class="text-sm text-slate-500 dark:text-slate-400"
        >
          {{ t('dashboard.activity.empty') }}
        </p>
        <ActivityFeed v-else :items="activity" />
      </div>
    </div>
  </main>
</template>
