<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import CardPickerCard from '@/pages/dashboard/scan/components/CardPickerCard.vue'
import ProgramPickerCard from '@/pages/dashboard/scan/components/ProgramPickerCard.vue'
import QrScannerView from '@/pages/dashboard/scan/components/QrScannerView.vue'
import ScanResultCard from '@/pages/dashboard/scan/components/ScanResultCard.vue'
import { rewardService } from '@/services/reward.service'
import { scanService, type ScanLookupResult } from '@/services/scan.service'
import { useAuthStore } from '@/stores/auth.store'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const auth = useAuthStore()
const { data: business } = useCurrentBusiness()

const scannerRef = ref<InstanceType<typeof QrScannerView> | null>(null)
const scanLookup = ref<ScanLookupResult | null>(null)
const errorMessage = ref('')
const successMessage = ref('')
const isRecordingVisit = ref(false)
const fulfillingRedemptionId = ref<string | null>(null)
const isJoining = ref(false)
const isPicking = ref(false)
const isRedeemingGoal = ref(false)

const readyResult = computed(() => (scanLookup.value?.kind === 'ready' ? scanLookup.value : null))
const newToBusinessResult = computed(() =>
  scanLookup.value?.kind === 'new-to-business' ? scanLookup.value : null,
)
const pickCardResult = computed(() =>
  scanLookup.value?.kind === 'pick-card' ? scanLookup.value : null,
)

async function handleDecode(code: string): Promise<void> {
  if (scanLookup.value || !business.value) return

  errorMessage.value = ''
  try {
    scanLookup.value = await scanService.lookupByCode(code, business.value.id)
    scannerRef.value?.stop()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handlePickProgram(programId: string): Promise<void> {
  const target = newToBusinessResult.value
  if (!target || !business.value) return

  isJoining.value = true
  errorMessage.value = ''
  try {
    const { customer, card } = await scanService.joinAndCreateCard(
      target.profileId,
      business.value.id,
      programId,
      target.firstName,
      target.lastName,
      target.email,
    )
    scanLookup.value = await scanService.pickCard(customer.id, card.id, business.value.id)
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isJoining.value = false
  }
}

async function handlePickCard(cardId: string): Promise<void> {
  const target = pickCardResult.value
  if (!target || !business.value) return

  isPicking.value = true
  errorMessage.value = ''
  try {
    scanLookup.value = await scanService.pickCard(target.customerId, cardId, business.value.id)
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isPicking.value = false
  }
}

async function handleRecordVisit(amountSpent: number | undefined): Promise<void> {
  const current = readyResult.value
  if (!current || !business.value || !auth.user) return

  isRecordingVisit.value = true
  errorMessage.value = ''
  try {
    const pointsEarned = await scanService.recordVisit(
      business.value.id,
      current.cardId,
      current.customerId,
      auth.user.id,
      amountSpent,
    )
    successMessage.value = t('dashboard.scan.visitRecorded', { n: pointsEarned })
    scanLookup.value = {
      ...current,
      currentPoints: current.currentPoints + pointsEarned,
      isGoalReached:
        current.goalReward !== null &&
        current.currentPoints + pointsEarned >= current.goalReward.pointsCost,
    }
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isRecordingVisit.value = false
  }
}

async function handleConfirmRedemption(redemptionId: string): Promise<void> {
  const current = readyResult.value
  if (!current || !business.value) return

  fulfillingRedemptionId.value = redemptionId
  errorMessage.value = ''
  try {
    await rewardService.fulfillRedemption(
      redemptionId,
      current.cardId,
      business.value.id,
      current.customerId,
    )
    const redeemed = current.pendingRedemptions.find((r) => r.id === redemptionId)
    scanLookup.value = {
      ...current,
      currentPoints: current.currentPoints - (redeemed?.pointsSpent ?? 0),
      pendingRedemptions: current.pendingRedemptions.filter((r) => r.id !== redemptionId),
    }
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    fulfillingRedemptionId.value = null
  }
}

async function handleRedeemGoal(): Promise<void> {
  const current = readyResult.value
  if (!current || !current.goalReward || !auth.user) return

  isRedeemingGoal.value = true
  errorMessage.value = ''
  try {
    scanLookup.value = await scanService.redeemGoal(
      current.cardId,
      current.goalReward.id,
      auth.user.id,
    )
    successMessage.value = t('dashboard.scan.goalRedeemed')
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isRedeemingGoal.value = false
  }
}

function handleScanAnother(): void {
  scanLookup.value = null
  successMessage.value = ''
  errorMessage.value = ''
}
</script>

<template>
  <DashboardTopbar :title="t('dashboard.scan.title')" />

  <main class="flex-1 p-6">
    <div class="mx-auto max-w-lg">
      <p class="text-sm text-slate-500 dark:text-slate-400">
        {{ t('dashboard.scan.instructions') }}
      </p>

      <p v-if="errorMessage" class="mt-3 text-sm text-rose-600 dark:text-rose-400">
        {{ errorMessage }}
      </p>
      <p v-if="successMessage" class="mt-3 text-sm text-success-600 dark:text-success-500">
        {{ successMessage }}
      </p>

      <div class="mt-4">
        <QrScannerView v-if="!scanLookup" ref="scannerRef" @decode="handleDecode" />

        <div v-else>
          <ProgramPickerCard
            v-if="newToBusinessResult"
            :result="newToBusinessResult"
            :is-joining="isJoining"
            @pick="handlePickProgram"
          />

          <CardPickerCard
            v-else-if="pickCardResult"
            :result="pickCardResult"
            :is-picking="isPicking"
            @pick="handlePickCard"
          />

          <ScanResultCard
            v-else-if="readyResult"
            :result="readyResult"
            :is-recording-visit="isRecordingVisit"
            :fulfilling-redemption-id="fulfillingRedemptionId"
            :is-redeeming-goal="isRedeemingGoal"
            @record-visit="handleRecordVisit"
            @confirm-redemption="handleConfirmRedemption"
            @redeem-goal="handleRedeemGoal"
          />

          <button
            type="button"
            class="mt-4 w-full rounded-lg border border-border px-4 py-2.5 text-sm font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
            @click="handleScanAnother"
          >
            {{ t('dashboard.scan.scanAnother') }}
          </button>
        </div>
      </div>
    </div>
  </main>
</template>
