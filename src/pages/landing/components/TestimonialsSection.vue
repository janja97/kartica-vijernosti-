<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import TestimonialCard from '@/components/marketing/TestimonialCard.vue'
import { useReveal } from '@/pages/landing/composables/useReveal'

interface Testimonial {
  quote: string
  name: string
  role: string
  initials: string
}

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.testimonials.items') as Testimonial[]
</script>

<template>
  <section id="testimonials" ref="target" class="border-y border-border bg-surface-raised py-28">
    <div class="mx-auto max-w-6xl px-6">
      <div class="reveal mx-auto max-w-2xl text-center" :class="{ 'reveal-visible': isVisible }">
        <p
          class="flex items-center justify-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.testimonials.eyebrow') }}
          <span class="h-px w-8 bg-accent-500" />
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.testimonials.title') }}
        </h2>
      </div>

      <div class="mt-16 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="(item, index) in items"
          :key="item.name"
          class="reveal"
          :class="{ 'reveal-visible': isVisible }"
          :style="{ transitionDelay: isVisible ? `${(index % 6) * 60}ms` : '0ms' }"
        >
          <TestimonialCard
            :quote="item.quote"
            :name="item.name"
            :role="item.role"
            :initials="item.initials"
          />
        </div>
      </div>
    </div>
  </section>
</template>
