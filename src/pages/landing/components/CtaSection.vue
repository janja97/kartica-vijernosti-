<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import { useReveal } from '@/pages/landing/composables/useReveal'

const { t } = useI18n()
const { target, isVisible } = useReveal()
</script>

<template>
  <section class="px-6 py-8">
    <div
      ref="target"
      class="reveal mx-auto max-w-5xl rounded-3xl border border-border bg-gradient-to-br from-brand-600 to-accent-500 py-20 text-center shadow-soft-lg"
      :class="{ 'reveal-visible': isVisible }"
    >
      <p
        class="flex items-center justify-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-white/70"
      >
        <span class="h-px w-8 bg-white/40" />
        {{ t('app.name') }}
        <span class="h-px w-8 bg-white/40" />
      </p>

      <h2
        class="mx-auto mt-6 max-w-2xl font-display text-4xl font-semibold leading-tight text-white sm:text-5xl"
      >
        {{ t('landing.cta.title') }}
      </h2>
      <p class="mx-auto mt-6 max-w-md text-base leading-relaxed text-white/80">
        {{ t('landing.cta.subtitle') }}
      </p>

      <RouterLink
        to="/auth/register"
        class="mt-10 inline-block rounded-full bg-white px-8 py-3.5 text-xs font-semibold uppercase tracking-widest text-brand-700 shadow-soft transition-transform duration-200 hover:-translate-y-0.5"
      >
        {{ t('landing.cta.button') }}
      </RouterLink>

      <p class="mt-5 text-xs uppercase tracking-widest text-white/70">
        {{ t('landing.cta.note') }}
      </p>
    </div>
  </section>
</template>
