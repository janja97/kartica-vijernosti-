<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { PickCardResult } from '@/services/scan.service'

defineProps<{
  result: PickCardResult
  isPicking: boolean
}>()

const emit = defineEmits<{
  pick: [cardId: string]
}>()

const { t } = useI18n()
</script>

<template>
  <div class="rounded-2xl border border-border bg-surface-raised p-6 shadow-soft">
    <p class="text-sm text-slate-600 dark:text-slate-300">
      {{ t('dashboard.scan.multipleCardsNotice') }}
    </p>

    <div class="mt-4 space-y-2">
      <button
        v-for="card in result.cards"
        :key="card.cardId"
        type="button"
        :disabled="isPicking"
        class="w-full rounded-lg border border-border px-4 py-2.5 text-left text-sm font-medium text-slate-900 transition-colors hover:border-brand-300 hover:bg-brand-50 disabled:cursor-not-allowed disabled:opacity-60 dark:text-white dark:hover:bg-brand-500/10"
        @click="emit('pick', card.cardId)"
      >
        {{ card.programName }}
      </button>
    </div>
  </div>
</template>
