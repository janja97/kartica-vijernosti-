<script setup lang="ts">
import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'
import type { MyCard } from '@/types/domain/card.types'

defineProps<{
  card: MyCard
}>()
</script>

<template>
  <RouterLink
    :to="`/app/cards/${card.id}`"
    class="block transition-transform duration-200 hover:-translate-y-0.5"
  >
    <LoyaltyCardVisual
      variant="compact"
      :business-name="card.businessName"
      :program-name="card.programName"
      :value="card.currentPoints"
      :goal="card.nextRewardThreshold"
    />
  </RouterLink>
</template>
