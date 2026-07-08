<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'
import type { MyCard } from '@/types/domain/card.types'

defineProps<{
  card: MyCard
}>()

const { t } = useI18n()
</script>

<template>
  <RouterLink
    :to="`/app/cards/${card.id}`"
    class="block transition-transform duration-200 hover:-translate-y-0.5"
    :class="card.isExpired ? 'opacity-60 grayscale' : ''"
  >
    <LoyaltyCardVisual
      variant="compact"
      :business-name="card.businessName"
      :program-name="card.programName"
      :value="card.currentPoints"
      :goal="card.nextRewardThreshold"
      :background-image-url="card.programImageUrl ?? card.businessLogoUrl"
      :seed="card.programId"
      :badge-label="card.isExpired ? t('portal.myCards.expiredBadge') : null"
    />
  </RouterLink>
</template>
