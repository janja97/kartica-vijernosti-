<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { ProgramPerformance } from '@/types/domain/analytics.types'

defineProps<{
  programs: ProgramPerformance[]
}>()

const { t } = useI18n()
</script>

<template>
  <div class="overflow-x-auto">
    <table class="w-full text-left text-sm">
      <thead>
        <tr
          class="border-b border-border text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400"
        >
          <th class="py-2 pr-4 font-medium">{{ t('dashboard.analytics.programs.nameColumn') }}</th>
          <th class="py-2 pr-4 font-medium">{{ t('dashboard.analytics.programs.cardsColumn') }}</th>
          <th class="py-2 pr-4 font-medium">
            {{ t('dashboard.analytics.programs.pointsColumn') }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="program in programs"
          :key="program.id"
          class="border-b border-border last:border-0"
        >
          <td class="py-2.5 pr-4 font-medium text-slate-900 dark:text-white">{{ program.name }}</td>
          <td class="py-2.5 pr-4 text-slate-600 dark:text-slate-300">{{ program.activeCards }}</td>
          <td class="py-2.5 pr-4 text-slate-600 dark:text-slate-300">
            {{ program.pointsBalance }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
