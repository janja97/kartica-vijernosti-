<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import type { BusinessCustomer } from '@/types/domain/customer.types'

defineProps<{
  customers: BusinessCustomer[]
}>()

const { t } = useI18n()

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString()
}
</script>

<template>
  <div class="overflow-x-auto rounded-2xl border border-border bg-surface-raised shadow-soft">
    <table class="w-full text-left text-sm">
      <thead
        class="border-b border-border text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400"
      >
        <tr>
          <th class="px-5 py-3 font-medium">{{ t('dashboard.customers.nameColumn') }}</th>
          <th class="px-5 py-3 font-medium">{{ t('dashboard.customers.pointsColumn') }}</th>
          <th class="px-5 py-3 font-medium">{{ t('dashboard.customers.joinedColumn') }}</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-border">
        <tr v-for="customer in customers" :key="customer.id">
          <td class="px-5 py-3">
            <div class="flex items-center gap-2">
              <p class="font-medium text-slate-900 dark:text-white">{{ customer.name }}</p>
              <span
                v-if="!customer.isVerified"
                class="rounded-full bg-accent-50 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-accent-700 dark:bg-accent-500/10 dark:text-accent-400"
              >
                {{ t('dashboard.customers.pendingBadge') }}
              </span>
            </div>
            <p v-if="customer.email" class="text-xs text-slate-500 dark:text-slate-400">
              {{ customer.email }}
            </p>
          </td>
          <td class="px-5 py-3 font-semibold text-brand-600 dark:text-brand-400">
            {{ customer.points }}
          </td>
          <td class="px-5 py-3 text-slate-500 dark:text-slate-400">
            {{ formatDate(customer.joinedAt) }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
