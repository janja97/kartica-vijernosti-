<script setup lang="ts">
import { BuildingStorefrontIcon } from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import type { BusinessDirectoryItem } from '@/types/domain/card.types'

defineProps<{
  business: BusinessDirectoryItem
}>()

const { t } = useI18n()
</script>

<template>
  <RouterLink
    :to="`/app/businesses/${business.id}`"
    class="flex flex-col rounded-2xl border border-border bg-surface-raised p-5 shadow-soft transition-shadow duration-200 hover:shadow-soft-lg"
  >
    <div
      class="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-50 text-brand-600 dark:bg-brand-500/10 dark:text-brand-400"
    >
      <BuildingStorefrontIcon class="h-6 w-6" />
    </div>
    <h3 class="mt-4 text-base font-semibold text-slate-900 dark:text-white">{{ business.name }}</h3>
    <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
      {{ t(`business.categories.${business.category}`) }}
      <span v-if="business.city"> · {{ business.city }}</span>
    </p>
    <p
      v-if="business.description"
      class="mt-2 line-clamp-2 text-sm text-slate-500 dark:text-slate-400"
    >
      {{ business.description }}
    </p>
  </RouterLink>
</template>
