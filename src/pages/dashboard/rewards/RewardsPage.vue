<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import IllustrationEmptyLoyaltyItems from '@/components/illustrations/IllustrationEmptyLoyaltyItems.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import RedemptionQueueList from '@/pages/dashboard/rewards/components/RedemptionQueueList.vue'
import RewardFormPanel from '@/pages/dashboard/rewards/components/RewardFormPanel.vue'
import RewardListItem from '@/pages/dashboard/rewards/components/RewardListItem.vue'
import {
  useInvalidateRewards,
  usePendingRedemptions,
  useRewards,
} from '@/pages/dashboard/rewards/composables/useRewards'
import { rewardService } from '@/services/reward.service'
import type { PendingRedemption, RewardCatalogItem } from '@/types/domain/reward.types'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const { data: rewards, isLoading, businessId } = useRewards()
const { data: pendingRedemptions, isLoading: isPendingLoading } = usePendingRedemptions()
const invalidate = useInvalidateRewards()

const isCreating = ref(false)
const editingReward = ref<RewardCatalogItem | null>(null)
const confirmingId = ref<string | null>(null)
const errorMessage = ref('')

async function handleCreate(input: {
  name: string
  description: string | null
  pointsCost: number
  type: 'discount' | 'free_item'
  discountPercent: number | null
  loyaltyProgramId: string
  isGoal: boolean
}): Promise<void> {
  const currentBusinessId = businessId()
  if (!currentBusinessId) return

  errorMessage.value = ''
  try {
    await rewardService.create(currentBusinessId, input)
    isCreating.value = false
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleUpdate(input: {
  name: string
  description: string | null
  pointsCost: number
  type: 'discount' | 'free_item'
  discountPercent: number | null
  loyaltyProgramId: string
  isGoal: boolean
}): Promise<void> {
  const currentBusinessId = businessId()
  if (!editingReward.value || !currentBusinessId) return

  errorMessage.value = ''
  try {
    await rewardService.update(editingReward.value.id, currentBusinessId, input)
    editingReward.value = null
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleToggleActive(reward: RewardCatalogItem): Promise<void> {
  const currentBusinessId = businessId()
  if (!currentBusinessId) return

  errorMessage.value = ''
  try {
    await rewardService.update(reward.id, currentBusinessId, { isActive: !reward.isActive })
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleConfirmRedemption(redemption: PendingRedemption): Promise<void> {
  const currentBusinessId = businessId()
  if (!currentBusinessId) return

  confirmingId.value = redemption.id
  errorMessage.value = ''
  try {
    await rewardService.fulfillRedemption(
      redemption.id,
      redemption.cardId,
      currentBusinessId,
      redemption.customerId,
    )
    await invalidate()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    confirmingId.value = null
  }
}
</script>

<template>
  <DashboardTopbar :title="t('dashboard.rewards.title')" />

  <main class="flex-1 space-y-8 p-6">
    <section>
      <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.rewards.pendingTitle') }}
      </h2>
      <div class="mt-3">
        <div v-if="isPendingLoading" class="h-16 animate-pulse rounded-xl bg-surface-raised" />
        <p
          v-else-if="!pendingRedemptions || pendingRedemptions.length === 0"
          class="text-sm text-slate-500 dark:text-slate-400"
        >
          {{ t('dashboard.rewards.pendingEmpty') }}
        </p>
        <RedemptionQueueList
          v-else
          :redemptions="pendingRedemptions"
          :confirming-id="confirmingId"
          @confirm="handleConfirmRedemption"
        />
      </div>
    </section>

    <section>
      <div class="flex items-center justify-between">
        <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
          {{ t('dashboard.rewards.title') }}
        </h2>
        <button
          v-if="!isCreating"
          type="button"
          class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
          @click="isCreating = true"
        >
          {{ t('dashboard.rewards.newButton') }}
        </button>
      </div>

      <p v-if="errorMessage" class="mt-3 text-sm text-rose-600 dark:text-rose-400">
        {{ errorMessage }}
      </p>

      <div class="mt-4 space-y-4">
        <RewardFormPanel v-if="isCreating" @save="handleCreate" @cancel="isCreating = false" />
        <RewardFormPanel
          v-if="editingReward"
          :reward="editingReward"
          @save="handleUpdate"
          @cancel="editingReward = null"
        />

        <div v-if="isLoading" class="space-y-3">
          <div v-for="n in 3" :key="n" class="h-20 animate-pulse rounded-2xl bg-surface-raised" />
        </div>

        <div v-else-if="!rewards || rewards.length === 0" class="py-10 text-center">
          <IllustrationEmptyLoyaltyItems kind="reward" />
          <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">
            {{ t('dashboard.rewards.empty') }}
          </p>
        </div>

        <div v-else class="space-y-3">
          <RewardListItem
            v-for="reward in rewards"
            :key="reward.id"
            :reward="reward"
            @edit="editingReward = reward"
            @toggle-active="handleToggleActive(reward)"
          />
        </div>
      </div>
    </section>
  </main>
</template>
