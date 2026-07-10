<script setup lang="ts">
import { CheckCircleIcon } from '@heroicons/vue/24/solid'
import { useI18n } from 'vue-i18n'

import DashboardPreviewMock from '@/components/marketing/DashboardPreviewMock.vue'
import { useReveal } from '@/pages/landing/composables/useReveal'

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const bullets = tm('landing.previews.dashboard.bullets') as string[]
</script>

<template>
  <section ref="target" class="mx-auto max-w-6xl px-6 py-24">
    <div class="grid items-center gap-16 md:grid-cols-2">
      <div class="reveal" :class="{ 'reveal-visible': isVisible }">
        <p
          class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.previews.dashboard.eyebrow') }}
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.previews.dashboard.title') }}
        </h2>
        <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
          {{ t('landing.previews.dashboard.subtitle') }}
        </p>
        <ul class="mt-8 space-y-3">
          <li
            v-for="bullet in bullets"
            :key="bullet"
            class="flex items-start gap-3 text-sm text-slate-600 dark:text-slate-300"
          >
            <CheckCircleIcon class="mt-0.5 h-5 w-5 flex-none text-success-500" />
            {{ bullet }}
          </li>
        </ul>
      </div>

      <div class="reveal" :class="{ 'reveal-visible': isVisible }" style="transition-delay: 120ms">
        <DashboardPreviewMock />
      </div>
    </div>
  </section>
</template>
