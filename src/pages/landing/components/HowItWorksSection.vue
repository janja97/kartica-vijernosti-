<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import HowItWorksIllustration from '@/components/illustrations/HowItWorksIllustration.vue'
import { useReveal } from '@/pages/landing/composables/useReveal'

interface StepItem {
  title: string
  description: string
}

const STEP_VARIANTS = ['signup', 'card', 'scan', 'reward'] as const

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const steps = tm('landing.how.steps') as StepItem[]
</script>

<template>
  <section
    id="how-it-works"
    ref="target"
    class="reveal mx-auto max-w-6xl px-6 py-28"
    :class="{ 'reveal-visible': isVisible }"
  >
    <div class="max-w-xl">
      <p
        class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
      >
        <span class="h-px w-8 bg-accent-500" />
        {{ t('landing.nav.howItWorks') }}
      </p>
      <h2
        class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
      >
        {{ t('landing.how.title') }}
      </h2>
      <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
        {{ t('landing.how.subtitle') }}
      </p>
    </div>

    <ol class="mt-16 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
      <li
        v-for="(step, index) in steps"
        :key="step.title"
        class="reveal rounded-2xl border border-border bg-surface-raised p-6 text-center shadow-soft"
        :class="{ 'reveal-visible': isVisible }"
        :style="{ transitionDelay: isVisible ? `${index * 90}ms` : '0ms' }"
      >
        <HowItWorksIllustration :variant="STEP_VARIANTS[index] ?? 'signup'" :size="88" />
        <p class="mt-4 text-xs font-semibold uppercase tracking-widest text-accent-500">
          {{ String(index + 1).padStart(2, '0') }}
        </p>
        <h3 class="mt-2 font-display text-lg font-semibold text-slate-900 dark:text-white">
          {{ step.title }}
        </h3>
        <p class="mt-2 text-sm leading-relaxed text-slate-500 dark:text-slate-400">
          {{ step.description }}
        </p>
      </li>
    </ol>
  </section>
</template>
