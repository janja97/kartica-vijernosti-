<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import AuthCard from '@/pages/auth/components/AuthCard.vue'
import AuthInput from '@/pages/auth/components/AuthInput.vue'
import { customerAuthService } from '@/services/customerAuth.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const router = useRouter()

const step = ref<'email' | 'code'>('email')
const email = ref('')
const code = ref('')
const isSubmitting = ref(false)
const errorMessage = ref('')

async function handleRequestCode(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true
  try {
    await customerAuthService.requestCode(email.value)
    step.value = 'code'
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSubmitting.value = false
  }
}

async function handleVerify(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true
  try {
    await customerAuthService.verifyCode(email.value, code.value)
    router.push('/app')
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <AuthCard
    :title="t('customerEntry.title')"
    :subtitle="
      step === 'email' ? t('customerEntry.emailSubtitle') : t('customerEntry.codeSubtitle')
    "
  >
    <form v-if="step === 'email'" class="space-y-4" @submit.prevent="handleRequestCode">
      <AuthInput
        v-model="email"
        :label="t('customerEntry.emailLabel')"
        type="email"
        autocomplete="email"
      />

      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">
        {{ errorMessage }}
      </p>

      <button
        type="submit"
        :disabled="isSubmitting"
        class="btn-ripple w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700 active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? t('common.loading') : t('customerEntry.sendCode') }}
      </button>
    </form>

    <form v-else class="space-y-4" @submit.prevent="handleVerify">
      <AuthInput
        v-model="code"
        :label="t('customerEntry.codeLabel')"
        type="text"
        autocomplete="one-time-code"
      />

      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">
        {{ errorMessage }}
      </p>

      <button
        type="submit"
        :disabled="isSubmitting"
        class="btn-ripple w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700 active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? t('common.loading') : t('customerEntry.verify') }}
      </button>

      <button
        type="button"
        class="w-full text-center text-xs text-slate-500 transition-colors hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200"
        @click="step = 'email'"
      >
        {{ t('customerEntry.backToEmail') }}
      </button>
    </form>
  </AuthCard>
</template>
