<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { RewardCatalogItem } from '@/types/domain/reward.types'

defineProps<{
  reward: RewardCatalogItem
}>()

const emit = defineEmits<{
  edit: []
  toggleActive: []
}>()

const { t } = useI18n()
</script>

<template>
  <div
    class="flex items-center justify-between rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
  >
    <div>
      <div class="flex items-center gap-2">
        <h3 class="text-base font-semibold text-slate-900 dark:text-white">{{ reward.name }}</h3>
        <span
          v-if="!reward.isActive"
          class="rounded-full bg-surface-sunken px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-slate-400"
        >
          {{ t('dashboard.programs.inactiveLabel') }}
        </span>
      </div>
      <p v-if="reward.description" class="mt-1 text-sm text-slate-500 dark:text-slate-400">
        {{ reward.description }}
      </p>
      <div class="mt-2 flex flex-wrap items-center gap-2">
        <span
          class="inline-flex rounded-full bg-accent-50 px-2.5 py-1 text-xs font-semibold text-accent-700 dark:bg-accent-500/10 dark:text-accent-400"
        >
          {{ reward.pointsCost }} {{ t('dashboard.topCustomers.pointsSuffix') }}
        </span>
        <span
          v-if="reward.type === 'discount' && reward.discountPercent !== null"
          class="inline-flex rounded-full bg-brand-50 px-2.5 py-1 text-xs font-semibold text-brand-700 dark:bg-brand-500/10 dark:text-brand-400"
        >
          -{{ reward.discountPercent }}%
        </span>
        <span
          v-else-if="reward.type === 'free_item'"
          class="inline-flex rounded-full bg-brand-50 px-2.5 py-1 text-xs font-semibold text-brand-700 dark:bg-brand-500/10 dark:text-brand-400"
        >
          {{ t('dashboard.rewards.form.types.free_item') }}
        </span>
      </div>
    </div>

    <div class="flex flex-none items-center gap-2">
      <button
        type="button"
        class="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
        @click="emit('edit')"
      >
        {{ t('dashboard.rewards.editButton') }}
      </button>
      <button
        type="button"
        class="rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
        @click="emit('toggleActive')"
      >
        {{ reward.isActive ? t('dashboard.rewards.deactivate') : t('dashboard.rewards.activate') }}
      </button>
    </div>
  </div>
</template>
