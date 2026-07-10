<script setup lang="ts">
import {
  AdjustmentsHorizontalIcon,
  CakeIcon,
  CalendarDaysIcon,
  ChartBarIcon,
  MapPinIcon,
  MoonIcon,
  PhotoIcon,
  QrCodeIcon,
  ShieldCheckIcon,
  TagIcon,
  UsersIcon,
} from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import FeatureCard from '@/components/marketing/FeatureCard.vue'
import { useReveal } from '@/pages/landing/composables/useReveal'

interface FeatureItem {
  title: string
  description: string
}

const icons = [
  AdjustmentsHorizontalIcon,
  TagIcon,
  CalendarDaysIcon,
  QrCodeIcon,
  PhotoIcon,
  ChartBarIcon,
  CakeIcon,
  UsersIcon,
  TagIcon,
  MapPinIcon,
  ShieldCheckIcon,
  MoonIcon,
]

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.featureGrid.items') as FeatureItem[]
</script>

<template>
  <section id="features" ref="target" class="border-y border-border bg-surface-raised py-28">
    <div class="mx-auto max-w-6xl px-6">
      <div class="reveal mx-auto max-w-2xl text-center" :class="{ 'reveal-visible': isVisible }">
        <p
          class="flex items-center justify-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.featureGrid.eyebrow') }}
          <span class="h-px w-8 bg-accent-500" />
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.featureGrid.title') }}
        </h2>
        <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
          {{ t('landing.featureGrid.subtitle') }}
        </p>
      </div>

      <div class="mt-16 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="(item, index) in items"
          :key="item.title"
          class="reveal"
          :class="{ 'reveal-visible': isVisible }"
          :style="{ transitionDelay: isVisible ? `${(index % 6) * 60}ms` : '0ms' }"
        >
          <FeatureCard
            :icon="icons[index] ?? icons[0]!"
            :title="item.title"
            :description="item.description"
          />
        </div>
      </div>
    </div>
  </section>
</template>
