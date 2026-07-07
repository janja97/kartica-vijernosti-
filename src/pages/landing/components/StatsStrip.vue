<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import { useCountUp } from '@/pages/landing/composables/useCountUp'
import { useReveal } from '@/pages/landing/composables/useReveal'

interface StatItem {
  value: string
  suffix: string
  label: string
}

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.stats.items') as StatItem[]

const targets = items.map((item) => computed(() => Number.parseInt(item.value, 10) || 0))
const counts = targets.map((t2) => useCountUp(t2, isVisible))
</script>

<template>
  <section
    ref="target"
    class="reveal border-y border-border bg-surface-raised"
    :class="{ 'reveal-visible': isVisible }"
  >
    <div
      class="mx-auto max-w-6xl divide-y divide-border sm:grid sm:grid-cols-4 sm:divide-x sm:divide-y-0"
    >
      <div v-for="(item, index) in items" :key="item.label" class="px-6 py-10 text-center sm:py-14">
        <p class="font-display text-4xl font-semibold text-slate-900 dark:text-white sm:text-5xl">
          {{ counts[index]?.value }}<span class="text-accent-500">{{ item.suffix }}</span>
        </p>
        <p class="mt-3 text-xs uppercase tracking-widest text-slate-500 dark:text-slate-400">
          {{ item.label }}
        </p>
      </div>
    </div>
    <p class="sr-only">{{ t('landing.stats.srLabel') }}</p>
  </section>
</template>
