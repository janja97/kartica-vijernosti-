<script setup lang="ts">
import { SparklesIcon } from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import type { ActivityItem } from '@/types/domain/dashboard.types'
import { formatRelativeTime } from '@/utils/formatRelativeTime'

defineProps<{
  items: ActivityItem[]
}>()

const { t } = useI18n()
</script>

<template>
  <ul class="space-y-1">
    <li
      v-for="item in items"
      :key="item.id"
      class="flex items-start gap-3 rounded-lg px-2 py-2.5 transition-colors hover:bg-surface-sunken"
    >
      <span
        class="flex h-8 w-8 flex-none items-center justify-center rounded-full bg-brand-50 text-brand-600 dark:bg-brand-500/10 dark:text-brand-400"
      >
        <SparklesIcon class="h-4 w-4" />
      </span>
      <div class="min-w-0">
        <p class="text-sm text-slate-700 dark:text-slate-200">
          {{ item.description ?? item.action }}
        </p>
        <p class="text-xs text-slate-400 dark:text-slate-500">
          {{
            t(`common.time.${formatRelativeTime(item.createdAt).unit}`, {
              n: formatRelativeTime(item.createdAt).n,
            })
          }}
        </p>
      </div>
    </li>
  </ul>
</template>
