<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'
import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { useLoyaltyPrograms } from '@/pages/dashboard/programs/composables/useLoyaltyPrograms'
import type { RewardCatalogItem } from '@/types/domain/reward.types'

const props = defineProps<{
  reward?: RewardCatalogItem | null
}>()

const emit = defineEmits<{
  save: [
    {
      name: string
      description: string | null
      pointsCost: number
      type: 'discount' | 'free_item'
      discountPercent: number | null
      loyaltyProgramId: string
      isGoal: boolean
    },
  ]
  cancel: []
}>()

const { t } = useI18n()
const { data: business } = useCurrentBusiness()
const { data: programs } = useLoyaltyPrograms()

const REWARD_TYPES = ['discount', 'free_item'] as const

const name = ref(props.reward?.name ?? '')
const description = ref(props.reward?.description ?? '')
const pointsCost = ref(String(props.reward?.pointsCost ?? 50))
const type = ref<'discount' | 'free_item'>(
  props.reward?.type === 'free_item' ? 'free_item' : 'discount',
)
const discountPercent = ref(
  props.reward?.discountPercent ? String(props.reward.discountPercent) : '',
)
const loyaltyProgramId = ref(props.reward?.loyaltyProgramId ?? '')
const isGoal = ref(props.reward?.isGoal ?? false)

const previewGoal = computed(() => Math.max(Number.parseFloat(pointsCost.value) || 0, 1))
const previewValue = computed(() => Math.round(previewGoal.value * 0.4))

function handleSubmit(): void {
  if (!loyaltyProgramId.value) return

  emit('save', {
    name: name.value,
    description: description.value || null,
    pointsCost: Number.parseFloat(pointsCost.value) || 0,
    type: type.value,
    discountPercent:
      type.value === 'discount' && discountPercent.value
        ? Number.parseFloat(discountPercent.value)
        : null,
    loyaltyProgramId: loyaltyProgramId.value,
    isGoal: isGoal.value,
  })
}
</script>

<template>
  <div class="grid gap-4 md:grid-cols-[1fr_320px]">
    <form
      class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
      @submit.prevent="handleSubmit"
    >
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.rewards.form.program') }}
        </label>
        <select
          v-model="loyaltyProgramId"
          required
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        >
          <option value="" disabled>{{ t('dashboard.rewards.form.programPlaceholder') }}</option>
          <option v-for="program in programs ?? []" :key="program.id" :value="program.id">
            {{ program.name }}
          </option>
        </select>
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.rewards.form.name') }}
        </label>
        <input
          v-model="name"
          type="text"
          required
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.rewards.form.description') }}
        </label>
        <textarea
          v-model="description"
          rows="2"
          :placeholder="t('dashboard.rewards.form.descriptionPlaceholder')"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.rewards.form.type') }}
        </label>
        <div class="grid grid-cols-2 gap-1 rounded-lg bg-surface-sunken p-1">
          <button
            v-for="option in REWARD_TYPES"
            :key="option"
            type="button"
            class="rounded-md px-3 py-1.5 text-xs font-semibold transition-colors"
            :class="
              type === option
                ? 'bg-surface-raised text-brand-600 shadow-sm dark:text-brand-400'
                : 'text-slate-500 dark:text-slate-400'
            "
            @click="type = option"
          >
            {{ t(`dashboard.rewards.form.types.${option}`) }}
          </button>
        </div>
      </div>

      <div v-if="type === 'discount'">
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.rewards.form.discountPercent') }}
        </label>
        <input
          v-model="discountPercent"
          type="number"
          min="0"
          max="100"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.rewards.form.pointsCost') }}
        </label>
        <input
          v-model="pointsCost"
          type="number"
          min="0"
          step="1"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <label
        class="flex items-center gap-2.5 rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-700 dark:text-slate-300"
      >
        <input
          v-model="isGoal"
          type="checkbox"
          class="h-4 w-4 rounded border-border text-brand-600 focus:ring-brand-500/30"
        />
        {{ t('dashboard.rewards.form.isGoal') }}
      </label>
      <p class="-mt-2 text-xs text-slate-500 dark:text-slate-400">
        {{ t('dashboard.rewards.form.isGoalHint') }}
      </p>

      <div class="flex gap-3">
        <button
          type="submit"
          class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
        >
          {{ t('dashboard.rewards.form.save') }}
        </button>
        <button
          type="button"
          class="rounded-lg border border-border px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
          @click="emit('cancel')"
        >
          {{ t('dashboard.rewards.form.cancel') }}
        </button>
      </div>
    </form>

    <div class="md:sticky md:top-4 md:self-start">
      <p
        class="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400"
      >
        {{ t('dashboard.rewards.form.previewTitle') }}
      </p>
      <LoyaltyCardVisual
        variant="detail"
        :business-name="business?.name ?? 'LoyalFlow'"
        :program-name="name || t('dashboard.rewards.form.name')"
        :value="previewValue"
        :goal="previewGoal"
        :goal-label="t('dashboard.rewards.form.previewGoalLabel')"
      />
    </div>
  </div>
</template>
