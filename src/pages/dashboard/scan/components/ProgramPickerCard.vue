<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { NewToBusinessResult } from '@/services/scan.service'

defineProps<{
  result: NewToBusinessResult
  isJoining: boolean
}>()

const emit = defineEmits<{
  pick: [programId: string]
}>()

const { t } = useI18n()
</script>

<template>
  <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft">
    <p class="text-lg font-semibold text-slate-900 dark:text-white">
      {{ result.firstName }} {{ result.lastName ?? '' }}
    </p>
    <p class="text-sm text-slate-500 dark:text-slate-400">{{ result.email }}</p>

    <p class="mt-4 text-sm text-slate-600 dark:text-slate-300">
      {{ t('dashboard.scan.newCustomerNotice') }}
    </p>

    <div class="mt-4 space-y-2">
      <button
        v-for="program in result.programs"
        :key="program.id"
        type="button"
        :disabled="isJoining"
        class="w-full rounded-lg border border-border px-4 py-2.5 text-left text-sm font-medium text-slate-900 transition-colors hover:border-brand-300 hover:bg-brand-50 disabled:cursor-not-allowed disabled:opacity-60 dark:text-white dark:hover:bg-brand-500/10"
        @click="emit('pick', program.id)"
      >
        {{ program.name }}
      </button>
    </div>
  </div>
</template>
