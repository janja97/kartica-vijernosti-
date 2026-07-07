<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import { useReveal } from '@/pages/landing/composables/useReveal'

interface BenefitItem {
  title: string
  description: string
}

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.benefits.items') as BenefitItem[]

function toOrdinal(index: number): string {
  return String(index + 1).padStart(2, '0')
}
</script>

<template>
  <section id="benefits" ref="target" class="border-y border-border bg-surface-raised py-28">
    <div class="mx-auto max-w-6xl px-6">
      <div class="reveal max-w-xl" :class="{ 'reveal-visible': isVisible }">
        <p
          class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.nav.benefits') }}
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.benefits.title') }}
        </h2>
        <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
          {{ t('landing.benefits.subtitle') }}
        </p>
      </div>

      <div class="mt-16 grid gap-x-12 gap-y-14 sm:grid-cols-2">
        <div
          v-for="(item, index) in items"
          :key="item.title"
          class="reveal border-t border-border pt-6"
          :class="{ 'reveal-visible': isVisible }"
          :style="{ transitionDelay: isVisible ? `${index * 60}ms` : '0ms' }"
        >
          <div class="flex items-baseline gap-4">
            <span class="font-display text-lg font-semibold text-accent-500">{{
              toOrdinal(index)
            }}</span>
            <h3 class="font-display text-xl font-semibold text-slate-900 dark:text-white">
              {{ item.title }}
            </h3>
          </div>
          <p class="mt-3 pl-9 text-sm leading-relaxed text-slate-500 dark:text-slate-400">
            {{ item.description }}
          </p>
        </div>
      </div>
    </div>
  </section>
</template>
