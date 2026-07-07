<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { TopCustomer } from '@/types/domain/dashboard.types'

defineProps<{
  customers: TopCustomer[]
}>()

const { t } = useI18n()

function initials(name: string): string {
  return name
    .split(' ')
    .map((part) => part[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()
}
</script>

<template>
  <ul class="space-y-1">
    <li
      v-for="(customer, index) in customers"
      :key="customer.id"
      class="flex items-center gap-3 rounded-lg px-2 py-2.5 transition-colors hover:bg-surface-sunken"
    >
      <span class="w-4 text-center text-xs font-semibold text-slate-400">{{ index + 1 }}</span>
      <span
        class="flex h-9 w-9 flex-none items-center justify-center rounded-full bg-gradient-to-br from-brand-500 to-accent-500 text-xs font-semibold text-white"
      >
        {{ initials(customer.name) }}
      </span>
      <div class="min-w-0 flex-1">
        <p class="truncate text-sm font-medium text-slate-900 dark:text-white">
          {{ customer.name }}
        </p>
        <p class="text-xs text-slate-500 dark:text-slate-400">
          {{ customer.visits }} {{ t('dashboard.topCustomers.visitsSuffix') }}
        </p>
      </div>
      <span class="text-sm font-semibold text-brand-600 dark:text-brand-400">
        {{ customer.points }} {{ t('dashboard.topCustomers.pointsSuffix') }}
      </span>
    </li>
  </ul>
</template>
