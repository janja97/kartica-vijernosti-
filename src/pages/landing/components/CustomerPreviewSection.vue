<script setup lang="ts">
import { CheckCircleIcon } from '@heroicons/vue/24/solid'
import { useI18n } from 'vue-i18n'

import CustomerPreviewMock from '@/components/marketing/CustomerPreviewMock.vue'
import { useReveal } from '@/pages/landing/composables/useReveal'

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const bullets = tm('landing.previews.customer.bullets') as string[]
</script>

<template>
  <section ref="target" class="border-y border-border bg-surface-raised py-24">
    <div class="mx-auto max-w-6xl px-6">
      <div class="grid items-center gap-16 md:grid-cols-2">
        <div class="reveal order-2 md:order-1" :class="{ 'reveal-visible': isVisible }">
          <CustomerPreviewMock />
        </div>

        <div class="reveal order-1 md:order-2" :class="{ 'reveal-visible': isVisible }">
          <p
            class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
          >
            <span class="h-px w-8 bg-accent-500" />
            {{ t('landing.previews.customer.eyebrow') }}
          </p>
          <h2
            class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
          >
            {{ t('landing.previews.customer.title') }}
          </h2>
          <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
            {{ t('landing.previews.customer.subtitle') }}
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
      </div>
    </div>
  </section>
</template>
