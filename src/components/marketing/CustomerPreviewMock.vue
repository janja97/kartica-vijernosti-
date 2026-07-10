<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import PreviewFrame from '@/components/marketing/PreviewFrame.vue'
import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'

const { t } = useI18n()
</script>

<template>
  <PreviewFrame url="app.loyalflow.hr/moje-kartice">
    <div class="mx-auto max-w-xs -space-y-16 pb-8 pt-2">
      <div class="rotate-[-5deg] opacity-80">
        <LoyaltyCardVisual
          business-name="Kafić Aroma"
          :program-name="t('landing.previews.customer.stampProgram')"
          :value="4"
          :goal="8"
          :goal-label="t('landing.previews.customer.stampGoal')"
          seed="aroma"
        />
      </div>
      <div class="relative rotate-[3deg]">
        <LoyaltyCardVisual
          business-name="Beauty Studio Bella"
          :program-name="t('landing.previews.customer.pointsProgram')"
          :value="180"
          :value-label="t('landing.previews.customer.pointsLabel')"
          :goal="240"
          :goal-label="t('landing.previews.customer.pointsGoal')"
          seed="bella"
        />
      </div>
    </div>
  </PreviewFrame>
</template>
