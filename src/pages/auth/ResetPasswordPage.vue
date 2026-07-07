<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import AuthCard from '@/pages/auth/components/AuthCard.vue'
import AuthInput from '@/pages/auth/components/AuthInput.vue'
import { authService } from '@/services/auth.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const router = useRouter()

const newPassword = ref('')
const isSubmitting = ref(false)
const errorMessage = ref('')
const isDone = ref(false)

async function handleSubmit(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true

  try {
    await authService.updatePassword(newPassword.value)
    isDone.value = true
    setTimeout(() => {
      void router.push('/auth/login')
    }, 2000)
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <AuthCard :title="t('auth.resetPassword.title')" :subtitle="t('auth.resetPassword.subtitle')">
    <form v-if="!isDone" class="space-y-4" @submit.prevent="handleSubmit">
      <AuthInput
        v-model="newPassword"
        :label="t('auth.resetPassword.newPassword')"
        type="password"
        placeholder="••••••••"
        autocomplete="new-password"
      />

      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>

      <button
        type="submit"
        :disabled="isSubmitting"
        class="w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700 active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? t('common.loading') : t('auth.resetPassword.submit') }}
      </button>
    </form>

    <p v-else class="text-center text-sm text-slate-600 dark:text-slate-300">
      {{ t('auth.resetPassword.success') }}
    </p>
  </AuthCard>
</template>
