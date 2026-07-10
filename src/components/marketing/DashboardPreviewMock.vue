<script setup lang="ts">
import { CalendarDaysIcon, CreditCardIcon, GiftIcon, UsersIcon } from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import PreviewFrame from '@/components/marketing/PreviewFrame.vue'
import StatCard from '@/pages/dashboard/components/StatCard.vue'
import VisitsChart from '@/pages/dashboard/components/VisitsChart.vue'

const { t } = useI18n()

const chartLabels = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned']
const chartValues = [18, 24, 21, 32, 41, 55, 38]
</script>

<template>
  <PreviewFrame url="app.loyalflow.hr/dashboard">
    <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
      <StatCard
        :label="t('landing.previews.dashboard.customers')"
        :value="1284"
        :icon="UsersIcon"
      />
      <StatCard
        :label="t('landing.previews.dashboard.activeCards')"
        :value="936"
        :icon="CreditCardIcon"
      />
      <StatCard
        :label="t('landing.previews.dashboard.todayVisits')"
        :value="47"
        :icon="CalendarDaysIcon"
      />
      <StatCard :label="t('landing.previews.dashboard.rewards')" :value="212" :icon="GiftIcon" />
    </div>
    <div class="mt-5">
      <VisitsChart :labels="chartLabels" :values="chartValues" />
    </div>
  </PreviewFrame>
</template>
