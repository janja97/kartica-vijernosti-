<script setup lang="ts">
import { ArrowTrendingDownIcon, ArrowTrendingUpIcon, UserPlusIcon } from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import VisitsChart from '@/pages/dashboard/components/VisitsChart.vue'
import StatCard from '@/pages/dashboard/components/StatCard.vue'
import ProgramPerformanceTable from '@/pages/dashboard/analytics/components/ProgramPerformanceTable.vue'
import {
  useAnalyticsSummary,
  useProgramPerformance,
  useVisitsChart30Days,
} from '@/pages/dashboard/analytics/composables/useAnalyticsData'

const { t } = useI18n()

const { data: summary, isLoading: isSummaryLoading } = useAnalyticsSummary()
const { data: chartPoints, isLoading: isChartLoading } = useVisitsChart30Days()
const { data: programs, isLoading: isProgramsLoading } = useProgramPerformance()
</script>

<template>
  <DashboardTopbar :title="t('dashboard.nav.analytics')" />

  <main class="flex-1 space-y-6 p-6">
    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
      <template v-if="isSummaryLoading">
        <div
          v-for="n in 3"
          :key="n"
          class="rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
        >
          <div class="h-3.5 w-24 animate-pulse rounded bg-surface-sunken" />
          <div class="mt-3 h-7 w-14 animate-pulse rounded bg-surface-sunken" />
        </div>
      </template>
      <template v-else>
        <StatCard
          :label="t('dashboard.analytics.pointsEarned')"
          :value="summary?.pointsEarned ?? 0"
          :icon="ArrowTrendingUpIcon"
        />
        <StatCard
          :label="t('dashboard.analytics.pointsRedeemed')"
          :value="summary?.pointsRedeemed ?? 0"
          :icon="ArrowTrendingDownIcon"
        />
        <StatCard
          :label="t('dashboard.analytics.newCustomers')"
          :value="summary?.newCustomers ?? 0"
          :icon="UserPlusIcon"
        />
      </template>
    </div>

    <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft">
      <h3 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.analytics.chartTitle') }}
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
        {{ t('dashboard.analytics.programs.title') }}
      </h3>
      <div class="mt-4">
        <div v-if="isProgramsLoading" class="space-y-3">
          <div v-for="n in 3" :key="n" class="h-9 animate-pulse rounded-lg bg-surface-sunken" />
        </div>
        <p
          v-else-if="!programs || programs.length === 0"
          class="text-sm text-slate-500 dark:text-slate-400"
        >
          {{ t('dashboard.analytics.programs.empty') }}
        </p>
        <ProgramPerformanceTable v-else :programs="programs" />
      </div>
    </div>
  </main>
</template>
