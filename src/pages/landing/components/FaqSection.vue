<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import FaqItem from '@/components/marketing/FaqItem.vue'
import { useReveal } from '@/pages/landing/composables/useReveal'

interface FaqEntry {
  question: string
  answer: string
}

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.faq.items') as FaqEntry[]
</script>

<template>
  <section id="faq" ref="target" class="mx-auto max-w-3xl px-6 py-28">
    <div class="reveal text-center" :class="{ 'reveal-visible': isVisible }">
      <p
        class="flex items-center justify-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
      >
        <span class="h-px w-8 bg-accent-500" />
        {{ t('landing.faq.eyebrow') }}
        <span class="h-px w-8 bg-accent-500" />
      </p>
      <h2
        class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
      >
        {{ t('landing.faq.title') }}
      </h2>
    </div>

    <div class="reveal mt-14" :class="{ 'reveal-visible': isVisible }">
      <FaqItem
        v-for="item in items"
        :key="item.question"
        :question="item.question"
        :answer="item.answer"
      />
    </div>
  </section>
</template>
