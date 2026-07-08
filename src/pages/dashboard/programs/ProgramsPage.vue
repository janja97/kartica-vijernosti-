<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import IllustrationEmptyLoyaltyItems from '@/components/illustrations/IllustrationEmptyLoyaltyItems.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import ProgramFormPanel from '@/pages/dashboard/programs/components/ProgramFormPanel.vue'
import ProgramListItem from '@/pages/dashboard/programs/components/ProgramListItem.vue'
import {
  useInvalidateLoyaltyPrograms,
  useLoyaltyPrograms,
} from '@/pages/dashboard/programs/composables/useLoyaltyPrograms'
import { loyaltyProgramService } from '@/services/loyaltyProgram.service'
import type { LoyaltyProgram } from '@/types/domain/card.types'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const { data: programs, isLoading, businessId } = useLoyaltyPrograms()
const invalidate = useInvalidateLoyaltyPrograms()

const isCreating = ref(false)
const editingProgram = ref<LoyaltyProgram | null>(null)
const errorMessage = ref('')

async function handleCreate(input: {
  name: string
  description: string | null
  pointsPerVisit: number
  minimumSpendAmount: number | null
  minimumSpendBonus: number | null
  expiryDays: number | null
  imageUrl: string | null
}): Promise<void> {
  const currentBusinessId = businessId()
  if (!currentBusinessId) return

  errorMessage.value = ''
  try {
    await loyaltyProgramService.create(currentBusinessId, input)
    isCreating.value = false
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleUpdate(input: {
  name: string
  description: string | null
  pointsPerVisit: number
  minimumSpendAmount: number | null
  minimumSpendBonus: number | null
  expiryDays: number | null
  imageUrl: string | null
}): Promise<void> {
  if (!editingProgram.value) return

  errorMessage.value = ''
  try {
    await loyaltyProgramService.update(editingProgram.value.id, input)
    editingProgram.value = null
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleToggleActive(program: LoyaltyProgram): Promise<void> {
  errorMessage.value = ''
  try {
    await loyaltyProgramService.update(program.id, { isActive: !program.isActive })
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}
</script>

<template>
  <DashboardTopbar :title="t('dashboard.programs.title')" />

  <main class="flex-1 space-y-4 p-6">
    <div class="flex items-center justify-between">
      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>
      <button
        v-if="!isCreating"
        type="button"
        class="ml-auto rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
        @click="isCreating = true"
      >
        {{ t('dashboard.programs.newButton') }}
      </button>
    </div>

    <ProgramFormPanel
      v-if="isCreating"
      :business-id="businessId() ?? ''"
      @save="handleCreate"
      @cancel="isCreating = false"
    />
    <ProgramFormPanel
      v-if="editingProgram"
      :program="editingProgram"
      :business-id="businessId() ?? ''"
      @save="handleUpdate"
      @cancel="editingProgram = null"
    />

    <div v-if="isLoading" class="space-y-3">
      <div v-for="n in 3" :key="n" class="h-20 animate-pulse rounded-2xl bg-surface-raised" />
    </div>

    <div v-else-if="!programs || programs.length === 0" class="py-10 text-center">
      <IllustrationEmptyLoyaltyItems kind="program" />
      <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">
        {{ t('dashboard.programs.empty') }}
      </p>
    </div>

    <div v-else class="space-y-3">
      <ProgramListItem
        v-for="program in programs"
        :key="program.id"
        :program="program"
        @edit="editingProgram = program"
        @toggle-active="handleToggleActive(program)"
      />
    </div>
  </main>
</template>
