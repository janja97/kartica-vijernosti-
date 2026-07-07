<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import ScanResultCard from '@/pages/dashboard/scan/components/ScanResultCard.vue'
import QrScannerView from '@/pages/dashboard/scan/components/QrScannerView.vue'
import DashboardTopbar from '@/pages/dashboard/components/DashboardTopbar.vue'
import { useCurrentBusiness } from '@/pages/dashboard/composables/useCurrentBusiness'
import { rewardService } from '@/services/reward.service'
import { scanService, type ScanResult } from '@/services/scan.service'
import { useAuthStore } from '@/stores/auth.store'
import { getErrorMessage } from '@/utils/getErrorMessage'

const { t } = useI18n()
const auth = useAuthStore()
const { data: business } = useCurrentBusiness()

const scannerRef = ref<InstanceType<typeof QrScannerView> | null>(null)
const scanResult = ref<ScanResult | null>(null)
const errorMessage = ref('')
const successMessage = ref('')
const isRecordingVisit = ref(false)
const fulfillingRedemptionId = ref<string | null>(null)

async function handleDecode(code: string): Promise<void> {
  if (scanResult.value || !business.value) return

  errorMessage.value = ''
  try {
    scanResult.value = await scanService.lookupByCode(code, business.value.id)
    scannerRef.value?.stop()
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

async function handleRecordVisit(amountSpent: number | undefined): Promise<void> {
  if (!scanResult.value || !business.value || !auth.user) return

  isRecordingVisit.value = true
  errorMessage.value = ''
  try {
    const pointsEarned = await scanService.recordVisit(
      business.value.id,
      scanResult.value.cardId,
      scanResult.value.customerId,
      auth.user.id,
      amountSpent,
    )
    successMessage.value = t('dashboard.scan.visitRecorded', { n: pointsEarned })
    scanResult.value = {
      ...scanResult.value,
      currentPoints: scanResult.value.currentPoints + pointsEarned,
    }
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isRecordingVisit.value = false
  }
}

async function handleConfirmRedemption(redemptionId: string): Promise<void> {
  if (!scanResult.value || !business.value) return

  fulfillingRedemptionId.value = redemptionId
  errorMessage.value = ''
  try {
    await rewardService.fulfillRedemption(
      redemptionId,
      scanResult.value.cardId,
      business.value.id,
      scanResult.value.customerId,
    )
    const redeemed = scanResult.value.pendingRedemptions.find((r) => r.id === redemptionId)
    scanResult.value = {
      ...scanResult.value,
      currentPoints: scanResult.value.currentPoints - (redeemed?.pointsSpent ?? 0),
      pendingRedemptions: scanResult.value.pendingRedemptions.filter((r) => r.id !== redemptionId),
    }
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    fulfillingRedemptionId.value = null
  }
}

function handleScanAnother(): void {
  scanResult.value = null
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
        <QrScannerView v-if="!scanResult" ref="scannerRef" @decode="handleDecode" />

        <div v-else>
          <ScanResultCard
            :result="scanResult"
            :is-recording-visit="isRecordingVisit"
            :fulfilling-redemption-id="fulfillingRedemptionId"
            @record-visit="handleRecordVisit"
            @confirm-redemption="handleConfirmRedemption"
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
