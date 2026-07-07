<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { PromoCodeInput } from '@/types/domain/marketing.types'

const emit = defineEmits<{
  save: [PromoCodeInput]
  cancel: []
}>()

const { t } = useI18n()

const code = ref('')
const description = ref('')
const discountPercent = ref('')
const discountAmount = ref('')
const maxRedemptions = ref('')
const expiresAt = ref('')

function handleSubmit(): void {
  emit('save', {
    code: code.value.trim().toUpperCase(),
    description: description.value || null,
    discountPercent: discountPercent.value ? Number.parseFloat(discountPercent.value) : null,
    discountAmount: discountAmount.value ? Number.parseFloat(discountAmount.value) : null,
    maxRedemptions: maxRedemptions.value ? Number.parseInt(maxRedemptions.value, 10) : null,
    expiresAt: expiresAt.value ? new Date(expiresAt.value).toISOString() : null,
  })
}
</script>

<template>
  <form
    class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
    @submit.prevent="handleSubmit"
  >
    <div>
      <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
        {{ t('dashboard.marketing.promoCodes.form.code') }}
      </label>
      <input
        v-model="code"
        type="text"
        required
        placeholder="LJETO2026"
        class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm uppercase text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
      />
    </div>

    <div>
      <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
        {{ t('dashboard.marketing.promoCodes.form.description') }}
      </label>
      <input
        v-model="description"
        type="text"
        class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
      />
    </div>

    <div class="grid gap-4 sm:grid-cols-2">
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.marketing.promoCodes.form.discountPercent') }}
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
          {{ t('dashboard.marketing.promoCodes.form.discountAmount') }}
        </label>
        <input
          v-model="discountAmount"
          type="number"
          min="0"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.marketing.promoCodes.form.maxRedemptions') }}
        </label>
        <input
          v-model="maxRedemptions"
          type="number"
          min="1"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.marketing.promoCodes.form.expiresAt') }}
        </label>
        <input
          v-model="expiresAt"
          type="date"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>
    </div>

    <div class="flex gap-3">
      <button
        type="submit"
        class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
      >
        {{ t('dashboard.marketing.promoCodes.form.save') }}
      </button>
      <button
        type="button"
        class="rounded-lg border border-border px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
        @click="emit('cancel')"
      >
        {{ t('dashboard.marketing.promoCodes.form.cancel') }}
      </button>
    </div>
  </form>
</template>
