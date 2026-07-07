<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import AuthCard from '@/pages/auth/components/AuthCard.vue'
import AuthInput from '@/pages/auth/components/AuthInput.vue'
import SocialAuthButton from '@/pages/auth/components/SocialAuthButton.vue'
import { authService } from '@/services/auth.service'
import { businessService } from '@/services/business.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const router = useRouter()

const email = ref('')
const password = ref('')
const rememberMe = ref(false)

const isSubmitting = ref(false)
const errorMessage = ref('')

async function handleSubmit(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true

  try {
    const session = await authService.signIn(email.value, password.value)
    const business = await businessService.getCurrentUserBusiness(session.user.id)
    await router.push(business ? '/dashboard' : '/app')
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSubmitting.value = false
  }
}

async function handleGoogleSignIn(): Promise<void> {
  errorMessage.value = ''
  try {
    await authService.signInWithGoogle()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}
</script>

<template>
  <AuthCard :title="t('auth.login.title')" :subtitle="t('auth.login.subtitle')">
    <form class="space-y-4" @submit.prevent="handleSubmit">
      <AuthInput
        v-model="email"
        :label="t('auth.fields.email')"
        type="email"
        placeholder="ana@obrt.hr"
        autocomplete="email"
      />
      <AuthInput
        v-model="password"
        :label="t('auth.fields.password')"
        type="password"
        placeholder="••••••••"
        autocomplete="current-password"
      />

      <div class="flex items-center justify-between text-sm">
        <label class="flex items-center gap-2 text-slate-600 dark:text-slate-300">
          <input
            v-model="rememberMe"
            type="checkbox"
            class="h-4 w-4 rounded border-border text-brand-600 focus:ring-brand-500/30"
          />
          {{ t('auth.login.rememberMe') }}
        </label>
        <RouterLink
          to="/auth/forgot-password"
          class="font-medium text-brand-600 hover:underline dark:text-brand-400"
        >
          {{ t('auth.login.forgotPassword') }}
        </RouterLink>
      </div>

      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>

      <button
        type="submit"
        :disabled="isSubmitting"
        class="w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700 active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? t('common.loading') : t('auth.login.submit') }}
      </button>
    </form>

    <div class="my-6 flex items-center gap-3">
      <div class="h-px flex-1 bg-border" />
      <span class="text-xs text-slate-400">{{ t('auth.orContinueWith') }}</span>
      <div class="h-px flex-1 bg-border" />
    </div>

    <SocialAuthButton :label="t('auth.google')" @click="handleGoogleSignIn" />

    <template #footer>
      {{ t('auth.login.noAccount') }}
      <RouterLink
        to="/auth/register"
        class="font-medium text-brand-600 hover:underline dark:text-brand-400"
      >
        {{ t('auth.login.registerLink') }}
      </RouterLink>
    </template>
  </AuthCard>
</template>
