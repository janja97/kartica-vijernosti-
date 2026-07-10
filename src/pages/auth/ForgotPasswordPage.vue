<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import AuthCard from '@/pages/auth/components/AuthCard.vue'
import AuthInput from '@/pages/auth/components/AuthInput.vue'
import { authService } from '@/services/auth.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()

const email = ref('')
const isSubmitted = ref(false)
const isSubmitting = ref(false)
const errorMessage = ref('')

async function handleSubmit(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true

  try {
    await authService.resetPassword(email.value)
    isSubmitted.value = true
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <AuthCard :title="t('auth.forgotPassword.title')" :subtitle="t('auth.forgotPassword.subtitle')">
    <form v-if="!isSubmitted" class="space-y-4" @submit.prevent="handleSubmit">
      <AuthInput
        v-model="email"
        :label="t('auth.fields.email')"
        type="email"
        placeholder="ana@obrt.hr"
        autocomplete="email"
      />

      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>

      <button
        type="submit"
        :disabled="isSubmitting"
        class="btn-ripple w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700 active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? t('common.loading') : t('auth.forgotPassword.submit') }}
      </button>
    </form>

    <p v-else class="text-center text-sm text-slate-600 dark:text-slate-300">
      {{ t('auth.forgotPassword.confirmation') }}
    </p>

    <template #footer>
      <RouterLink
        to="/auth/login"
        class="font-medium text-brand-600 hover:underline dark:text-brand-400"
      >
        {{ t('auth.forgotPassword.backToLogin') }}
      </RouterLink>
    </template>
  </AuthCard>
</template>
