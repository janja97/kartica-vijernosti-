<script setup lang="ts">
import { useQueryClient } from '@tanstack/vue-query'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'
import QrCodeDisplay from '@/pages/portal/card-detail/components/QrCodeDisplay.vue'
import { useCardDetail } from '@/pages/portal/card-detail/composables/useCardDetail'
import { customerPortalService } from '@/services/customerPortal.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const props = defineProps<{
  cardId: string
}>()

const { t } = useI18n()
const queryClient = useQueryClient()

const cardId = computed(() => props.cardId)
const { data: card, isLoading } = useCardDetail(cardId)

const requestingRewardId = ref<string | null>(null)
const requestedRewardIds = ref<Set<string>>(new Set())
const errorMessage = ref('')

async function handleRedeem(rewardId: string): Promise<void> {
  errorMessage.value = ''
  requestingRewardId.value = rewardId

  try {
    await customerPortalService.requestRedemption(props.cardId, rewardId)
    requestedRewardIds.value.add(rewardId)
    await queryClient.invalidateQueries({ queryKey: ['card-detail', props.cardId] })
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    requestingRewardId.value = null
  }
}
</script>

<template>
  <div v-if="isLoading" class="space-y-4">
    <div class="h-48 animate-pulse rounded-2xl bg-surface-raised" />
  </div>

  <div v-else-if="card" class="grid gap-8 md:grid-cols-[1fr_1.2fr]">
    <div>
      <LoyaltyCardVisual
        variant="detail"
        :business-name="card.businessName"
        :program-name="card.programName"
        :value="card.currentPoints"
        :goal="card.nextRewardThreshold"
        :background-image-url="card.programImageUrl ?? card.businessLogoUrl"
        :seed="card.programId"
        :badge-label="card.isExpired ? t('portal.myCards.expiredBadge') : null"
      />

      <p
        v-if="card.isExpired"
        class="mt-4 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700 dark:border-rose-500/20 dark:bg-rose-500/10 dark:text-rose-400"
      >
        {{ t('portal.cardDetail.expiredNotice') }}
      </p>

      <div class="mt-6">
        <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
          {{ t('portal.cardDetail.qrTitle') }}
        </h2>
        <p class="mt-1 text-xs text-slate-500 dark:text-slate-400">
          {{ t('portal.cardDetail.qrHint') }}
        </p>
        <div class="mt-4">
          <QrCodeDisplay :value="card.qrCode" />
        </div>
      </div>
    </div>

    <div>
      <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('portal.cardDetail.rewardsTitle') }}
      </h2>

      <p v-if="errorMessage" class="mt-3 text-sm text-rose-600 dark:text-rose-400">
        {{ errorMessage }}
      </p>

      <p v-if="card.rewards.length === 0" class="mt-4 text-sm text-slate-500 dark:text-slate-400">
        {{ t('portal.cardDetail.noRewards') }}
      </p>

      <ul v-else class="mt-4 space-y-3">
        <li
          v-for="reward in card.rewards"
          :key="reward.id"
          class="flex items-center justify-between gap-4 rounded-xl border border-border bg-surface-raised p-4 shadow-soft"
        >
          <div class="min-w-0">
            <p class="text-sm font-medium text-slate-900 dark:text-white">{{ reward.name }}</p>
            <div class="mt-1 flex flex-wrap items-center gap-1.5">
              <span
                class="inline-flex rounded-full bg-accent-50 px-2 py-0.5 text-xs font-semibold text-accent-700 dark:bg-accent-500/10 dark:text-accent-400"
              >
                {{ reward.pointsCost }} {{ t('dashboard.topCustomers.pointsSuffix') }}
              </span>
              <span
                v-if="reward.type === 'discount' && reward.discountPercent !== null"
                class="inline-flex rounded-full bg-brand-50 px-2 py-0.5 text-xs font-semibold text-brand-700 dark:bg-brand-500/10 dark:text-brand-400"
              >
                -{{ reward.discountPercent }}%
              </span>
            </div>
          </div>

          <span
            v-if="requestedRewardIds.has(reward.id)"
            class="text-xs font-medium text-success-600 dark:text-success-500"
          >
            {{ t('portal.cardDetail.redeemRequested') }}
          </span>
          <button
            v-else-if="reward.affordable && !card.isExpired"
            type="button"
            :disabled="requestingRewardId === reward.id"
            class="flex-none rounded-lg bg-brand-600 px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
            @click="handleRedeem(reward.id)"
          >
            {{ t('portal.cardDetail.redeemButton') }}
          </button>
          <span v-else class="flex-none text-xs text-slate-400 dark:text-slate-500">
            {{ t('portal.cardDetail.notEnoughPoints') }}
          </span>
        </li>
      </ul>
    </div>
  </div>
</template>
