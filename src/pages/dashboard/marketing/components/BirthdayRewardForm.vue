<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BirthdayRewardType } from '@/types/database.types'
import type { BirthdayRewardConfig } from '@/types/domain/marketing.types'

const props = defineProps<{
  config: BirthdayRewardConfig
  isSaving: boolean
}>()

const emit = defineEmits<{
  save: [BirthdayRewardConfig]
}>()

const { t } = useI18n()

const REWARD_TYPES: BirthdayRewardType[] = [
  'discount',
  'points_bonus',
  'free_item',
  'free_service',
  'gift',
  'none',
]

const isEnabled = ref(props.config.isEnabled)
const rewardType = ref<BirthdayRewardType>(props.config.rewardType)
const rewardAmount = ref(
  props.config.rewardAmount !== null ? String(props.config.rewardAmount) : '',
)
const daysBefore = ref(String(props.config.daysBefore))
const validDays = ref(String(props.config.validDays))

const showAmountField = computed(
  () => rewardType.value === 'discount' || rewardType.value === 'points_bonus',
)

function handleSubmit(): void {
  emit('save', {
    isEnabled: isEnabled.value,
    rewardType: rewardType.value,
    rewardAmount: showAmountField.value ? Number.parseFloat(rewardAmount.value) || 0 : null,
    daysBefore: Number.parseInt(daysBefore.value, 10) || 0,
    validDays: Number.parseInt(validDays.value, 10) || 7,
  })
}
</script>

<template>
  <form
    class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
    @submit.prevent="handleSubmit"
  >
    <div class="flex items-center justify-between">
      <h2 class="text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.marketing.birthday.title') }}
      </h2>
      <label class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
        <input
          v-model="isEnabled"
          type="checkbox"
          class="h-4 w-4 rounded border-border text-brand-600 focus:ring-brand-500/30"
        />
        {{ t('dashboard.marketing.birthday.enabled') }}
      </label>
    </div>
    <p class="text-sm text-slate-500 dark:text-slate-400">
      {{ t('dashboard.marketing.birthday.description') }}
    </p>

    <div class="grid gap-4 sm:grid-cols-2">
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.marketing.birthday.rewardType') }}
        </label>
        <select
          v-model="rewardType"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        >
          <option v-for="option in REWARD_TYPES" :key="option" :value="option">
            {{ t(`dashboard.marketing.birthday.rewardTypes.${option}`) }}
          </option>
        </select>
      </div>

      <div v-if="showAmountField">
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{
            rewardType === 'discount'
              ? t('dashboard.marketing.birthday.discountPercent')
              : t('dashboard.marketing.birthday.pointsAmount')
          }}
        </label>
        <input
          v-model="rewardAmount"
          type="number"
          min="0"
          step="1"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.marketing.birthday.daysBefore') }}
        </label>
        <input
          v-model="daysBefore"
          type="number"
          min="0"
          step="1"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.marketing.birthday.validDays') }}
        </label>
        <input
          v-model="validDays"
          type="number"
          min="1"
          step="1"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>
    </div>

    <button
      type="submit"
      :disabled="isSaving"
      class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
    >
      {{ isSaving ? t('common.loading') : t('dashboard.settings.saveButton') }}
    </button>
  </form>
</template>
