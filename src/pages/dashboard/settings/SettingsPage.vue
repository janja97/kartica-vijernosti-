<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import {
  useCurrentBusiness,
  useInvalidateCurrentBusiness,
} from '@/pages/dashboard/composables/useCurrentBusiness'
import { useInvalidateProfile, useProfile } from '@/pages/dashboard/composables/useProfile'
import BusinessInfoForm from '@/pages/dashboard/settings/components/BusinessInfoForm.vue'
import PasswordForm from '@/pages/dashboard/settings/components/PasswordForm.vue'
import ProfileInfoForm from '@/pages/dashboard/settings/components/ProfileInfoForm.vue'
import { authService } from '@/services/auth.service'
import { businessService } from '@/services/business.service'
import { profileService } from '@/services/profile.service'
import type { BusinessUpdateInput } from '@/types/domain/business.types'
import type { ProfileUpdateInput } from '@/types/domain/profile.types'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()

const { data: business, isLoading: isBusinessLoading } = useCurrentBusiness()
const invalidateBusiness = useInvalidateCurrentBusiness()
const { data: profile, isLoading: isProfileLoading } = useProfile()
const invalidateProfile = useInvalidateProfile()

const canEditBusiness = computed(
  () => business.value?.currentUserRole === 'owner' || business.value?.currentUserRole === 'admin',
)

const isSavingBusiness = ref(false)
const isSavingProfile = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

async function handleSaveBusiness(input: BusinessUpdateInput): Promise<void> {
  if (!business.value) return

  errorMessage.value = ''
  successMessage.value = ''
  isSavingBusiness.value = true
  try {
    await businessService.updateBusiness(business.value.id, input)
    await invalidateBusiness()
    successMessage.value = t('dashboard.settings.saved')
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSavingBusiness.value = false
  }
}

async function handleSaveProfile(input: ProfileUpdateInput): Promise<void> {
  if (!profile.value) return

  errorMessage.value = ''
  successMessage.value = ''
  isSavingProfile.value = true
  try {
    await profileService.updateProfile(profile.value.id, input)
    await invalidateProfile()
    successMessage.value = t('dashboard.settings.saved')
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSavingProfile.value = false
  }
}

async function handleSavePassword(newPassword: string): Promise<void> {
  errorMessage.value = ''
  successMessage.value = ''
  try {
    await authService.updatePassword(newPassword)
    successMessage.value = t('dashboard.settings.password.success')
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}
</script>

<template>
  <DashboardTopbar :title="t('dashboard.nav.settings')" />

  <main class="flex-1 space-y-6 p-6">
    <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>
    <p v-if="successMessage" class="text-sm text-emerald-600 dark:text-emerald-400">
      {{ successMessage }}
    </p>

    <div v-if="isBusinessLoading || isProfileLoading" class="space-y-4">
      <div v-for="n in 3" :key="n" class="h-48 animate-pulse rounded-2xl bg-surface-raised" />
    </div>

    <template v-else>
      <BusinessInfoForm
        v-if="canEditBusiness && business"
        :business="business"
        :is-saving="isSavingBusiness"
        @save="handleSaveBusiness"
      />

      <ProfileInfoForm
        v-if="profile"
        :profile="profile"
        :is-saving="isSavingProfile"
        @save="handleSaveProfile"
      />

      <PasswordForm @save="handleSavePassword" />
    </template>
  </main>
</template>
