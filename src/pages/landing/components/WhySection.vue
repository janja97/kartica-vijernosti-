<script setup lang="ts">
import { CheckCircleIcon } from '@heroicons/vue/24/solid'
import { useI18n } from 'vue-i18n'

import { useReveal } from '@/pages/landing/composables/useReveal'

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.why.items') as string[]
</script>

<template>
  <section id="why" ref="target" class="mx-auto max-w-6xl px-6 py-28">
    <div class="grid gap-16 md:grid-cols-[0.8fr_1.2fr] md:items-center">
      <div class="reveal" :class="{ 'reveal-visible': isVisible }">
        <p
          class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.why.eyebrow') }}
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.why.title') }}
        </h2>
        <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
          {{ t('landing.why.subtitle') }}
        </p>
      </div>

      <div class="grid gap-4 sm:grid-cols-2">
        <div
          v-for="(item, index) in items"
          :key="item"
          class="reveal flex items-start gap-3 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
          :class="{ 'reveal-visible': isVisible }"
          :style="{ transitionDelay: isVisible ? `${index * 70}ms` : '0ms' }"
        >
          <CheckCircleIcon class="mt-0.5 h-5 w-5 flex-none text-success-500" />
          <p class="text-sm leading-relaxed text-slate-600 dark:text-slate-300">{{ item }}</p>
        </div>
      </div>
    </div>
  </section>
</template>
