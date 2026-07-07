<script setup lang="ts">
import { refDebounced } from '@vueuse/core'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import IllustrationEmptyDirectory from '@/components/illustrations/IllustrationEmptyDirectory.vue'
import { BUSINESS_CATEGORIES } from '@/constants/businessCategories'
import BusinessCard from '@/pages/portal/directory/components/BusinessCard.vue'
import { useBusinessDirectory } from '@/pages/portal/directory/composables/useBusinessDirectory'
import type { BusinessCategory } from '@/types/database.types'

const { t } = useI18n()

const selectedCategory = ref<BusinessCategory | ''>('')
const cityQuery = ref('')
const debouncedCity = refDebounced(cityQuery, 300)

const filters = computed(() => ({
  category: selectedCategory.value || undefined,
  city: debouncedCity.value || undefined,
}))
const hasActiveFilters = computed(() => selectedCategory.value !== '' || cityQuery.value !== '')

const { data: businesses, isLoading } = useBusinessDirectory(filters)
</script>

<template>
  <div>
    <h1 class="font-display text-2xl font-semibold tracking-tight text-slate-900 dark:text-white">
      {{ t('portal.directory.title') }}
    </h1>
    <p class="mt-2 text-sm text-slate-500 dark:text-slate-400">
      {{ t('portal.directory.subtitle') }}
    </p>

    <div class="mt-6 flex flex-col gap-3 sm:flex-row">
      <select
        v-model="selectedCategory"
        class="w-full rounded-lg border border-border bg-surface-raised px-3 py-2.5 text-sm text-slate-900 focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/30 dark:text-white sm:w-56"
      >
        <option value="">{{ t('portal.directory.filters.categoryAll') }}</option>
        <option v-for="category in BUSINESS_CATEGORIES" :key="category" :value="category">
          {{ t(`business.categories.${category}`) }}
        </option>
      </select>

      <input
        v-model="cityQuery"
        type="text"
        :placeholder="t('portal.directory.filters.cityPlaceholder')"
        class="w-full rounded-lg border border-border bg-surface-raised px-3 py-2.5 text-sm text-slate-900 placeholder:text-slate-400 focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/30 dark:text-white sm:w-56"
      />
    </div>

    <div v-if="isLoading" class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <div v-for="n in 6" :key="n" class="h-36 animate-pulse rounded-2xl bg-surface-raised" />
    </div>

    <div v-else-if="!businesses || businesses.length === 0" class="mt-8 py-6 text-center">
      <IllustrationEmptyDirectory />
      <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">
        {{ hasActiveFilters ? t('portal.directory.noMatches') : t('portal.directory.empty') }}
      </p>
    </div>

    <div v-else class="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <BusinessCard v-for="business in businesses" :key="business.id" :business="business" />
    </div>
  </div>
</template>
