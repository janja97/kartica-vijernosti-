<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { PendingRedemption } from '@/types/domain/reward.types'

defineProps<{
  redemptions: PendingRedemption[]
  confirmingId: string | null
}>()

const emit = defineEmits<{
  confirm: [redemption: PendingRedemption]
}>()

const { t } = useI18n()
</script>

<template>
  <ul class="space-y-2">
    <li
      v-for="redemption in redemptions"
      :key="redemption.id"
      class="flex items-center justify-between rounded-xl border border-border bg-surface-raised px-4 py-3 shadow-soft"
    >
      <div>
        <p class="text-sm font-medium text-slate-900 dark:text-white">
          {{ redemption.customerName }} — {{ redemption.rewardName }}
        </p>
        <p class="text-xs text-slate-500 dark:text-slate-400">
          {{ redemption.pointsSpent }} {{ t('dashboard.topCustomers.pointsSuffix') }}
        </p>
      </div>
      <button
        type="button"
        :disabled="confirmingId === redemption.id"
        class="rounded-lg bg-success-600 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-success-700 disabled:cursor-not-allowed disabled:opacity-60"
        @click="emit('confirm', redemption)"
      >
        {{ t('dashboard.rewards.confirmButton') }}
      </button>
    </li>
  </ul>
</template>
