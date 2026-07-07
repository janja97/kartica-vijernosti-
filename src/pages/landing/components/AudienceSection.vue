<script setup lang="ts">
import { useI18n } from 'vue-i18n'

import { useReveal } from '@/pages/landing/composables/useReveal'

interface AudienceItem {
  label: string
}

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.audience.items') as AudienceItem[]
</script>

<template>
  <section
    id="audience"
    ref="target"
    class="reveal mx-auto max-w-6xl px-6 py-28"
    :class="{ 'reveal-visible': isVisible }"
  >
    <div class="grid gap-12 md:grid-cols-[0.7fr_1.3fr]">
      <div>
        <p
          class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.nav.audience') }}
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.audience.title') }}
        </h2>
        <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
          {{ t('landing.audience.subtitle') }}
        </p>
      </div>

      <div>
        <p class="font-display text-2xl leading-relaxed text-slate-900 dark:text-white sm:text-3xl">
          <template v-for="(item, index) in items" :key="item.label">
            <span class="transition-colors hover:text-accent-500">{{ item.label }}</span
            ><span v-if="index < items.length - 1" class="text-slate-400 dark:text-slate-500">
              &nbsp;·&nbsp;
            </span>
          </template>
        </p>
        <p class="mt-8 border-t border-border pt-6 text-sm text-slate-500 dark:text-slate-400">
          {{ t('landing.audience.more') }}
        </p>
      </div>
    </div>
  </section>
</template>
