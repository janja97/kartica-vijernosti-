<script setup lang="ts">
import { useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import { useBusinessDetail } from '@/pages/portal/business-detail/composables/useBusinessDetail'
import { useMyCards } from '@/pages/portal/my-cards/composables/useMyCards'
import { customerPortalService } from '@/services/customerPortal.service'
import { useAuthStore } from '@/stores/auth.store'
import { getErrorMessage } from '@/utils/getErrorMessage'

const props = defineProps<{
  businessId: string
}>()

const { t } = useI18n()
const router = useRouter()
const auth = useAuthStore()
const queryClient = useQueryClient()

const businessId = computed(() => props.businessId)
const { data: business, isLoading } = useBusinessDetail(businessId)
const { data: myCards } = useMyCards()

const joiningProgramId = ref<string | null>(null)
const errorMessage = ref('')

function cardForProgram(programId: string): string | null {
  const match = myCards.value?.find(
    (card) => card.businessId === props.businessId && card.programId === programId,
  )
  return match?.id ?? null
}

function isJoined(programId: string): boolean {
  return cardForProgram(programId) !== null
}

async function handleJoin(programId: string): Promise<void> {
  if (!auth.user) return
  errorMessage.value = ''
  joiningProgramId.value = programId

  try {
    const cardId = await customerPortalService.joinProgram(
      auth.user.id,
      props.businessId,
      programId,
    )
    await queryClient.invalidateQueries({ queryKey: ['my-cards'] })
    await router.push(`/app/cards/${cardId}`)
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    joiningProgramId.value = null
  }
}
</script>

<template>
  <div v-if="isLoading" class="space-y-4">
    <div class="h-8 w-1/3 animate-pulse rounded bg-surface-raised" />
    <div class="h-32 animate-pulse rounded-2xl bg-surface-raised" />
  </div>

  <div v-else-if="business">
    <h1 class="font-display text-2xl font-semibold tracking-tight text-slate-900 dark:text-white">
      {{ business.name }}
    </h1>
    <p v-if="business.city" class="mt-1 text-sm text-slate-500 dark:text-slate-400">
      {{ business.city }}
    </p>
    <p v-if="business.description" class="mt-4 max-w-xl text-sm text-slate-600 dark:text-slate-300">
      {{ business.description }}
    </p>

    <h2
      class="mt-8 text-sm font-semibold uppercase tracking-wide text-slate-500 dark:text-slate-400"
    >
      {{ t('portal.businessDetail.programsTitle') }}
    </h2>

    <p v-if="errorMessage" class="mt-3 text-sm text-rose-600 dark:text-rose-400">
      {{ errorMessage }}
    </p>

    <p
      v-if="business.programs.length === 0"
      class="mt-4 text-sm text-slate-500 dark:text-slate-400"
    >
      {{ t('portal.businessDetail.noPrograms') }}
    </p>

    <div v-else class="mt-4 grid gap-4 sm:grid-cols-2">
      <div
        v-for="program in business.programs"
        :key="program.id"
        class="rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
      >
        <h3 class="text-base font-semibold text-slate-900 dark:text-white">{{ program.name }}</h3>
        <p v-if="program.description" class="mt-2 text-sm text-slate-500 dark:text-slate-400">
          {{ program.description }}
        </p>

        <RouterLink
          v-if="isJoined(program.id)"
          :to="`/app/cards/${cardForProgram(program.id)}`"
          class="mt-4 inline-block text-sm font-medium text-brand-600 hover:underline dark:text-brand-400"
        >
          {{ t('portal.businessDetail.alreadyJoined') }}
        </RouterLink>
        <button
          v-else
          type="button"
          :disabled="joiningProgramId === program.id"
          class="btn-ripple mt-4 rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
          @click="handleJoin(program.id)"
        >
          {{
            joiningProgramId === program.id
              ? t('common.loading')
              : t('portal.businessDetail.joinButton')
          }}
        </button>
      </div>
    </div>
  </div>
</template>
