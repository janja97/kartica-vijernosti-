<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import IllustrationEmptyCards from '@/components/illustrations/IllustrationEmptyCards.vue'
import WalletCard from '@/pages/portal/my-cards/components/WalletCard.vue'
import { useMyCards } from '@/pages/portal/my-cards/composables/useMyCards'

const { t } = useI18n()
const { data: cards, isLoading } = useMyCards()
</script>

<template>
  <div>
    <h1 class="font-display text-2xl font-semibold tracking-tight text-slate-900 dark:text-white">
      {{ t('portal.myCards.title') }}
    </h1>

    <div v-if="isLoading" class="mt-8 grid gap-4 sm:grid-cols-2">
      <div v-for="n in 2" :key="n" class="h-40 animate-pulse rounded-2xl bg-surface-raised" />
    </div>

    <div
      v-else-if="!cards || cards.length === 0"
      class="mt-8 rounded-2xl border border-dashed border-border p-10 text-center"
    >
      <IllustrationEmptyCards />
      <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">{{ t('portal.myCards.empty') }}</p>
      <RouterLink
        to="/app/businesses"
        class="mt-4 inline-block rounded-lg bg-brand-600 px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
      >
        {{ t('portal.myCards.browseCta') }}
      </RouterLink>
    </div>

    <div v-else class="mt-8">
      <div class="flex flex-col sm:hidden">
        <div
          v-for="(card, index) in cards"
          :key="card.id"
          class="transition-transform"
          :class="[index > 0 ? '-mt-24' : '', index % 2 === 0 ? 'rotate-1' : '-rotate-1']"
          :style="{ zIndex: index }"
        >
          <WalletCard :card="card" />
        </div>
      </div>

      <div class="hidden gap-4 sm:grid sm:grid-cols-2">
        <WalletCard v-for="card in cards" :key="card.id" :card="card" />
      </div>
    </div>
  </div>
</template>
