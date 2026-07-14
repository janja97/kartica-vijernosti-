<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import IllustrationEmptyCustomers from '@/components/illustrations/IllustrationEmptyCustomers.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import AddCustomerPanel from '@/pages/dashboard/customers/components/AddCustomerPanel.vue'
import CustomersTable from '@/pages/dashboard/customers/components/CustomersTable.vue'
import {
  useBusinessCustomers,
  useInvalidateBusinessCustomers,
} from '@/pages/dashboard/customers/composables/useBusinessCustomers'
import { customerService } from '@/services/customer.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const { data: customers, isLoading, businessId } = useBusinessCustomers()
const invalidate = useInvalidateBusinessCustomers()

const isCreating = ref(false)
const errorMessage = ref('')

async function handleCreate(input: {
  firstName: string
  lastName: string | null
  email: string
}): Promise<void> {
  const currentBusinessId = businessId()
  if (!currentBusinessId) return

  errorMessage.value = ''
  try {
    await customerService.createByEmail(
      currentBusinessId,
      input.email,
      input.firstName,
      input.lastName,
    )
    isCreating.value = false
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}
</script>

<template>
  <DashboardTopbar :title="t('dashboard.customers.title')" />

  <main class="flex-1 space-y-4 p-6">
    <div class="flex items-center justify-between">
      <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.customers.title') }}
      </h2>
      <button
        v-if="!isCreating"
        type="button"
        class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
        @click="isCreating = true"
      >
        {{ t('dashboard.customers.newButton') }}
      </button>
    </div>

    <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">
      {{ errorMessage }}
    </p>

    <AddCustomerPanel v-if="isCreating" @save="handleCreate" @cancel="isCreating = false" />

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
