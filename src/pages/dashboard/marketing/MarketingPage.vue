<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import IllustrationEmptyPromo from '@/components/illustrations/IllustrationEmptyPromo.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import BirthdayRewardForm from '@/pages/dashboard/marketing/components/BirthdayRewardForm.vue'
import PromoCodeFormPanel from '@/pages/dashboard/marketing/components/PromoCodeFormPanel.vue'
import PromoCodeListItem from '@/pages/dashboard/marketing/components/PromoCodeListItem.vue'
import ReferralToggle from '@/pages/dashboard/marketing/components/ReferralToggle.vue'
import {
  useBirthdayReward,
  useInvalidateBirthdayReward,
  useInvalidatePromoCodes,
  useInvalidateReferralEnabled,
  usePromoCodes,
  useReferralEnabled,
} from '@/pages/dashboard/marketing/composables/useMarketing'
import { marketingService } from '@/services/marketing.service'
import type {
  BirthdayRewardConfig,
  PromoCode,
  PromoCodeInput,
} from '@/types/domain/marketing.types'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()

const { data: business } = useCurrentBusiness()
const canManage = computed(
  () => business.value?.currentUserRole === 'owner' || business.value?.currentUserRole === 'admin',
)

const { data: birthdayReward, isLoading: isBirthdayLoading, businessId } = useBirthdayReward()
const invalidateBirthdayReward = useInvalidateBirthdayReward()

const { data: referralEnabled, isLoading: isReferralLoading } = useReferralEnabled()
const invalidateReferralEnabled = useInvalidateReferralEnabled()

const { data: promoCodes, isLoading: isPromoCodesLoading } = usePromoCodes()
const invalidatePromoCodes = useInvalidatePromoCodes()

const isSavingBirthday = ref(false)
const isSavingReferral = ref(false)
const isCreatingPromoCode = ref(false)
const errorMessage = ref('')

async function handleSaveBirthday(input: BirthdayRewardConfig): Promise<void> {
  const currentBusinessId = businessId()
  if (!currentBusinessId) return

  errorMessage.value = ''
  isSavingBirthday.value = true
  try {
    await marketingService.saveBirthdayReward(currentBusinessId, input)
    await invalidateBirthdayReward()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSavingBirthday.value = false
  }
}

async function handleToggleReferral(enabled: boolean): Promise<void> {
  if (!business.value) return

  errorMessage.value = ''
  isSavingReferral.value = true
  try {
    await marketingService.setReferralEnabled(business.value.id, enabled)
    await invalidateReferralEnabled()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isSavingReferral.value = false
  }
}

async function handleCreatePromoCode(input: PromoCodeInput): Promise<void> {
  if (!business.value) return

  errorMessage.value = ''
  try {
    await marketingService.createPromoCode(business.value.id, input)
    isCreatingPromoCode.value = false
    await invalidatePromoCodes()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleTogglePromoCode(promoCode: PromoCode): Promise<void> {
  errorMessage.value = ''
  try {
    await marketingService.setPromoCodeActive(promoCode.id, !promoCode.isActive)
    await invalidatePromoCodes()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}
</script>

<template>
  <DashboardTopbar :title="t('dashboard.nav.marketing')" />

  <main class="flex-1 space-y-6 p-6">
    <p v-if="errorMessage" class="text-sm text-rose-600 dark:text-rose-400">{{ errorMessage }}</p>

    <template v-if="canManage">
      <div v-if="isBirthdayLoading" class="h-56 animate-pulse rounded-2xl bg-surface-raised" />
      <BirthdayRewardForm
        v-else-if="birthdayReward"
        :config="birthdayReward"
        :is-saving="isSavingBirthday"
        @save="handleSaveBirthday"
      />

      <div v-if="isReferralLoading" class="h-24 animate-pulse rounded-2xl bg-surface-raised" />
      <ReferralToggle
        v-else
        :enabled="referralEnabled ?? true"
        :is-saving="isSavingReferral"
        @toggle="handleToggleReferral"
      />

      <section>
        <div class="flex items-center justify-between">
          <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
            {{ t('dashboard.marketing.promoCodes.title') }}
          </h2>
          <button
            v-if="!isCreatingPromoCode"
            type="button"
            class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
            @click="isCreatingPromoCode = true"
          >
            {{ t('dashboard.marketing.promoCodes.newButton') }}
          </button>
        </div>

        <div class="mt-4 space-y-3">
          <PromoCodeFormPanel
            v-if="isCreatingPromoCode"
            @save="handleCreatePromoCode"
            @cancel="isCreatingPromoCode = false"
          />

          <div v-if="isPromoCodesLoading" class="space-y-3">
            <div v-for="n in 2" :key="n" class="h-20 animate-pulse rounded-2xl bg-surface-raised" />
          </div>
          <div v-else-if="!promoCodes || promoCodes.length === 0" class="py-10 text-center">
            <IllustrationEmptyPromo />
            <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">
              {{ t('dashboard.marketing.promoCodes.empty') }}
            </p>
          </div>
          <template v-else>
            <PromoCodeListItem
              v-for="promoCode in promoCodes"
              :key="promoCode.id"
              :promo-code="promoCode"
              @toggle-active="handleTogglePromoCode(promoCode)"
            />
          </template>
        </div>
      </section>
    </template>

    <p v-else class="text-sm text-slate-500 dark:text-slate-400">
      {{ t('dashboard.marketing.managerOnly') }}
    </p>
  </main>
</template>
