<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import IllustrationEmptyCustomers from '@/components/illustrations/IllustrationEmptyCustomers.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import CustomersTable from '@/pages/dashboard/customers/components/CustomersTable.vue'
import { useBusinessCustomers } from '@/pages/dashboard/customers/composables/useBusinessCustomers'

const { t } = useI18n()
const { data: customers, isLoading } = useBusinessCustomers()
</script>

<template>
  <DashboardTopbar :title="t('dashboard.customers.title')" />

  <main class="flex-1 p-6">
    <div v-if="isLoading" class="space-y-3">
      <div v-for="n in 5" :key="n" class="h-12 animate-pulse rounded-lg bg-surface-raised" />
    </div>

    <div v-else-if="!customers || customers.length === 0" class="py-10 text-center">
      <IllustrationEmptyCustomers />
      <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">
        {{ t('dashboard.customers.empty') }}
      </p>
    </div>

    <CustomersTable v-else :customers="customers" />
  </main>
</template>
