<script setup lang="ts">
import { ArrowTrendingDownIcon, ArrowTrendingUpIcon, UserPlusIcon } from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import PreviewFrame from '@/components/marketing/PreviewFrame.vue'
import StatCard from '@/pages/dashboard/components/StatCard.vue'
import VisitsChart from '@/pages/dashboard/components/VisitsChart.vue'

const { t } = useI18n()

const chartLabels = ['Tj 1', 'Tj 2', 'Tj 3', 'Tj 4']
const chartValues = [420, 512, 486, 601]
</script>

<template>
  <PreviewFrame url="app.loyalflow.hr/analitika">
    <div class="grid grid-cols-3 gap-3">
      <StatCard
        :label="t('landing.previews.analytics.pointsEarned')"
        :value="3260"
        :icon="ArrowTrendingUpIcon"
      />
      <StatCard
        :label="t('landing.previews.analytics.pointsRedeemed')"
        :value="1180"
        :icon="ArrowTrendingDownIcon"
      />
      <StatCard
        :label="t('landing.previews.analytics.newCustomers')"
        :value="96"
        :icon="UserPlusIcon"
      />
    </div>
    <div class="mt-5">
      <VisitsChart :labels="chartLabels" :values="chartValues" />
    </div>
  </PreviewFrame>
</template>
