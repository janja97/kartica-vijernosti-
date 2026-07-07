<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'
import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import type { LoyaltyProgram } from '@/types/domain/card.types'

const props = defineProps<{
  program?: LoyaltyProgram | null
}>()

const emit = defineEmits<{
  save: [{ name: string; description: string | null; pointsPerVisit: number }]
  cancel: []
}>()

const { t } = useI18n()
const { data: business } = useCurrentBusiness()

const name = ref(props.program?.name ?? '')
const description = ref(props.program?.description ?? '')
const pointsPerVisit = ref(String(props.program?.pointsPerVisit ?? 10))

const previewGoal = computed(() => Math.max((Number.parseFloat(pointsPerVisit.value) || 0) * 5, 1))
const previewValue = computed(() => Math.round(previewGoal.value * 0.4))

function handleSubmit(): void {
  emit('save', {
    name: name.value,
    description: description.value || null,
    pointsPerVisit: Number.parseFloat(pointsPerVisit.value) || 0,
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
          {{ t('dashboard.programs.form.name') }}
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
          {{ t('dashboard.programs.form.description') }}
        </label>
        <textarea
          v-model="description"
          rows="2"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.programs.form.pointsPerVisit') }}
        </label>
        <input
          v-model="pointsPerVisit"
          type="number"
          min="0"
          step="1"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div class="flex gap-3">
        <button
          type="submit"
          class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
        >
          {{ t('dashboard.programs.form.save') }}
        </button>
        <button
          type="button"
          class="rounded-lg border border-border px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
          @click="emit('cancel')"
        >
          {{ t('dashboard.programs.form.cancel') }}
        </button>
      </div>
    </form>

    <div class="md:sticky md:top-4 md:self-start">
      <p
        class="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400"
      >
        {{ t('dashboard.programs.form.previewTitle') }}
      </p>
      <LoyaltyCardVisual
        variant="detail"
        :business-name="business?.name ?? 'LoyalFlow'"
        :program-name="name || t('dashboard.programs.form.name')"
        :value="previewValue"
        :goal="previewGoal"
        :goal-label="t('dashboard.programs.form.previewGoalLabel')"
      />
    </div>
  </div>
</template>
