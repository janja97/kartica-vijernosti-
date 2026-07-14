<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import ProgressRing from '@/components/ui/ProgressRing.vue'
import { useNumberChangeAnimation } from '@/composables/useNumberChangeAnimation'
import type { ScanResult } from '@/services/scan.service'

const props = defineProps<{
  result: ScanResult
  isRecordingVisit: boolean
  fulfillingRedemptionId: string | null
  isRedeemingGoal: boolean
}>()

const emit = defineEmits<{
  recordVisit: [amountSpent: number | undefined]
  confirmRedemption: [redemptionId: string]
  redeemGoal: []
}>()

const { t } = useI18n()
const amount = ref('')

const pointsRef = computed(() => props.result.currentPoints)
const { isPulsing } = useNumberChangeAnimation(pointsRef)

function handleRecordVisit(): void {
  const parsed = Number.parseFloat(amount.value)
  emit('recordVisit', Number.isFinite(parsed) && parsed > 0 ? parsed : undefined)
}
</script>

<template>
  <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft">
    <div class="flex items-center justify-between gap-4">
      <div>
        <p class="text-lg font-semibold text-slate-900 dark:text-white">
          {{ result.customerName }}
        </p>
        <p class="text-sm text-slate-500 dark:text-slate-400">{{ result.programName }}</p>
        <p
          class="mt-3 font-display text-3xl font-bold text-brand-600 transition-transform dark:text-brand-400"
          :class="{ 'animate-stamp-pop': isPulsing }"
        >
          {{ result.currentPoints }}
        </p>
      </div>
      <ProgressRing
        v-if="result.nextRewardThreshold"
        :value="result.currentPoints"
        :max="result.nextRewardThreshold"
        :size="72"
        :stroke-width="6"
        color="accent"
        show-label
      />
    </div>

    <p
      v-if="result.isExpired"
      class="mt-4 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700 dark:border-rose-500/20 dark:bg-rose-500/10 dark:text-rose-400"
    >
      {{ t('dashboard.scan.expiredNotice') }}
    </p>

    <div
      v-if="!result.isExpired && result.isGoalReached && result.goalReward"
      class="mt-4 rounded-xl border border-success-200 bg-success-50 px-4 py-3 dark:border-success-500/20 dark:bg-success-500/10"
    >
      <p class="text-sm font-semibold text-success-700 dark:text-success-400">
        {{ t('dashboard.scan.goalReached', { reward: result.goalReward.name }) }}
      </p>
      <button
        type="button"
        :disabled="props.isRedeemingGoal"
        class="mt-2.5 w-full rounded-lg bg-success-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-success-700 disabled:cursor-not-allowed disabled:opacity-60"
        @click="emit('redeemGoal')"
      >
        {{ props.isRedeemingGoal ? t('common.loading') : t('dashboard.scan.redeemGoal') }}
      </button>
    </div>

    <div v-if="!result.isExpired" class="mt-5">
      <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
        {{ t('dashboard.scan.amountLabel') }}
      </label>
      <input
        v-model="amount"
        type="number"
        min="0"
        step="0.01"
        class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
      />
      <button
        type="button"
        :disabled="props.isRecordingVisit"
        class="mt-3 w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
        @click="handleRecordVisit"
      >
        {{ props.isRecordingVisit ? t('common.loading') : t('dashboard.scan.recordVisit') }}
      </button>
    </div>

    <div v-if="result.pendingRedemptions.length > 0" class="mt-6 border-t border-border pt-5">
      <h3 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.scan.pendingRedemptions') }}
      </h3>
      <ul class="mt-3 space-y-2">
        <li
          v-for="redemption in result.pendingRedemptions"
          :key="redemption.id"
          class="flex items-center justify-between rounded-lg bg-surface-sunken px-3 py-2.5"
        >
          <div>
            <p class="text-sm font-medium text-slate-900 dark:text-white">
              {{ redemption.rewardName }}
            </p>
            <p class="text-xs text-slate-500 dark:text-slate-400">
              {{ redemption.pointsSpent }} {{ t('dashboard.topCustomers.pointsSuffix') }}
            </p>
          </div>
          <button
            type="button"
            :disabled="props.fulfillingRedemptionId === redemption.id"
            class="rounded-lg bg-success-600 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-success-700 disabled:cursor-not-allowed disabled:opacity-60"
            @click="emit('confirmRedemption', redemption.id)"
          >
            {{ t('dashboard.scan.confirmRedemption') }}
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>
