<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import { BUSINESS_CATEGORIES } from '@/constants/businessCategories'
import AuthCard from '@/pages/auth/components/AuthCard.vue'
import AuthInput from '@/pages/auth/components/AuthInput.vue'
import SocialAuthButton from '@/pages/auth/components/SocialAuthButton.vue'
import { authService } from '@/services/auth.service'
import type { BusinessCategory } from '@/types/database.types'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const router = useRouter()

type RegisterMode = 'business' | 'customer'
const mode = ref<RegisterMode>('business')

const businessName = ref('')
const businessCategory = ref<BusinessCategory | ''>('')
const businessCity = ref('')
const firstName = ref('')
const lastName = ref('')
const email = ref('')
const password = ref('')
const acceptTerms = ref(false)

const isSubmitting = ref(false)
const errorMessage = ref('')
const isAwaitingConfirmation = ref(false)

function switchMode(next: RegisterMode): void {
  mode.value = next
  errorMessage.value = ''
}

async function handleSubmit(): Promise<void> {
  errorMessage.value = ''
  isSubmitting.value = true

  try {
    const { session } = await authService.signUp(email.value, password.value, {
      businessName: mode.value === 'business' ? businessName.value : undefined,
      businessCategory: mode.value === 'business' ? businessCategory.value || undefined : undefined,
      businessCity: mode.value === 'business' ? businessCity.value : undefined,
      firstName: mode.value === 'customer' ? firstName.value : undefined,
      lastName: mode.value === 'customer' ? lastName.value : undefined,
    })

    if (session) {
      await router.push(mode.value === 'business' ? '/dashboard' : '/app')
    } else {
      isAwaitingConfirmation.value = true
    }
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
  <AuthCard :title="t('auth.register.title')" :subtitle="t('auth.register.subtitle')">
    <div
      v-if="!isAwaitingConfirmation"
      class="mb-6 grid grid-cols-2 gap-1 rounded-lg bg-surface-sunken p-1"
    >
      <button
        type="button"
        class="rounded-md px-3 py-1.5 text-xs font-semibold transition-colors"
        :class="
          mode === 'business'
            ? 'bg-surface-raised text-brand-600 shadow-sm dark:text-brand-400'
            : 'text-slate-500 dark:text-slate-400'
        "
        @click="switchMode('business')"
      >
        {{ t('auth.register.asBusinessTab') }}
      </button>
      <button
        type="button"
        class="rounded-md px-3 py-1.5 text-xs font-semibold transition-colors"
        :class="
          mode === 'customer'
            ? 'bg-surface-raised text-brand-600 shadow-sm dark:text-brand-400'
            : 'text-slate-500 dark:text-slate-400'
        "
        @click="switchMode('customer')"
      >
        {{ t('auth.register.asCustomerTab') }}
      </button>
    </div>

    <p v-if="isAwaitingConfirmation" class="text-center text-sm text-slate-600 dark:text-slate-300">
      {{ t('auth.register.confirmEmail') }}
    </p>

    <form v-else class="space-y-4" @submit.prevent="handleSubmit">
      <template v-if="mode === 'business'">
        <AuthInput
          v-model="businessName"
          :label="t('auth.fields.businessName')"
          placeholder="Kafić Aroma"
          autocomplete="organization"
        />

        <div>
          <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-200">
            {{ t('auth.fields.category') }}
          </label>
          <select
            v-model="businessCategory"
            class="w-full rounded-lg border border-border bg-surface-raised px-3 py-2.5 text-sm text-slate-900 focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/30 dark:text-white"
          >
            <option value="" disabled>{{ t('auth.fields.categoryPlaceholder') }}</option>
            <option v-for="category in BUSINESS_CATEGORIES" :key="category" :value="category">
              {{ t(`business.categories.${category}`) }}
            </option>
          </select>
        </div>

        <AuthInput
          v-model="businessCity"
          :label="t('auth.fields.city')"
          placeholder="Zagreb"
          autocomplete="address-level2"
        />
      </template>
      <template v-else>
        <AuthInput
          v-model="firstName"
          :label="t('auth.fields.firstName')"
          autocomplete="given-name"
        />
        <AuthInput
          v-model="lastName"
          :label="t('auth.fields.lastName')"
          autocomplete="family-name"
        />
      </template>

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
        autocomplete="new-password"
      />

      <label class="flex items-start gap-2 text-sm text-slate-600 dark:text-slate-300">
        <input
          v-model="acceptTerms"
          type="checkbox"
          required
          class="mt-0.5 h-4 w-4 rounded border-border text-brand-600 focus:ring-brand-500/30"
        />
        <span>{{ t('auth.register.termsNotice') }}</span>
      </label>

      <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>

      <button
        type="submit"
        :disabled="isSubmitting"
        class="btn-ripple w-full rounded-lg bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700 active:translate-y-0 disabled:cursor-not-allowed disabled:opacity-60"
      >
        {{ isSubmitting ? t('common.loading') : t('auth.register.submit') }}
      </button>
    </form>

    <template v-if="!isAwaitingConfirmation">
      <div class="my-6 flex items-center gap-3">
        <div class="h-px flex-1 bg-border" />
        <span class="text-xs text-slate-400">{{ t('auth.orContinueWith') }}</span>
        <div class="h-px flex-1 bg-border" />
      </div>

      <SocialAuthButton :label="t('auth.google')" @click="handleGoogleSignIn" />
    </template>

    <template #footer>
      {{ t('auth.register.haveAccount') }}
      <RouterLink
        to="/auth/login"
        class="font-medium text-brand-600 hover:underline dark:text-brand-400"
      >
        {{ t('auth.register.loginLink') }}
      </RouterLink>
    </template>
  </AuthCard>
</template>
