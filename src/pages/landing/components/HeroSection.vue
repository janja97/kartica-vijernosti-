<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'

const { t } = useI18n()

const isMounted = ref(false)
onMounted(() => {
  requestAnimationFrame(() => {
    isMounted.value = true
  })
})
</script>

<template>
  <section class="relative overflow-hidden">
    <div
      class="pointer-events-none absolute left-1/2 top-0 h-[44rem] w-[44rem] -translate-x-1/2 rounded-full border border-border opacity-60"
    />
    <div
      class="pointer-events-none absolute -right-16 top-16 h-72 w-72 animate-blob rounded-full bg-accent-300/40 blur-3xl dark:bg-accent-500/20"
    />
    <div
      class="pointer-events-none absolute right-32 top-56 h-72 w-72 animate-blob rounded-full bg-brand-300/40 blur-3xl dark:bg-brand-500/20"
      style="animation-delay: -7s"
    />

    <div class="relative mx-auto max-w-6xl px-6 pb-24 pt-20 md:pt-28">
      <div class="grid gap-16 md:grid-cols-[1.1fr_0.9fr] md:items-end">
        <div class="reveal" :class="{ 'reveal-visible': isMounted }">
          <p
            class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
          >
            <span class="h-px w-8 bg-accent-500" />
            {{ t('landing.hero.eyebrow') }}
          </p>

          <h1
            class="mt-8 font-display text-5xl font-semibold leading-[1.05] tracking-tight text-slate-900 dark:text-white sm:text-6xl lg:text-7xl"
          >
            {{ t('landing.hero.titleLine1') }}
            <span class="text-accent-500">{{ t('landing.hero.titleHighlight') }}</span>
            {{ t('landing.hero.titleLine2') }}
          </h1>

          <p class="mt-8 max-w-md text-lg leading-relaxed text-slate-500 dark:text-slate-400">
            {{ t('landing.hero.subtitle') }}
          </p>

          <div class="mt-10 flex flex-wrap items-center gap-6">
            <RouterLink
              to="/auth/register"
              class="rounded-full bg-accent-600 px-7 py-3.5 text-xs font-semibold uppercase tracking-widest text-white shadow-soft-lg transition-all duration-200 hover:-translate-y-0.5 hover:bg-accent-700"
            >
              {{ t('landing.hero.ctaPrimary') }}
            </RouterLink>
            <a
              href="#how-it-works"
              class="group flex items-center gap-2 text-xs font-medium uppercase tracking-widest text-slate-900 dark:text-white"
            >
              {{ t('landing.hero.ctaSecondary') }}
              <span class="h-px w-6 bg-accent-500 transition-all duration-300 group-hover:w-10" />
            </a>
          </div>

          <p
            class="mt-8 max-w-md border-t border-border pt-6 text-sm leading-relaxed text-slate-500 dark:text-slate-400"
          >
            {{ t('landing.hero.subtitleExtra') }}
          </p>
        </div>

        <div
          class="reveal flex justify-center md:justify-end"
          :class="{ 'reveal-visible': isMounted }"
          style="transition-delay: 150ms"
        >
          <div class="w-full max-w-sm">
            <LoyaltyCardVisual
              variant="hero"
              glass
              :business-name="t('landing.hero.card.business')"
              :badge-label="t('landing.hero.card.member')"
              :value="Number(t('landing.hero.card.points'))"
              :value-label="t('landing.hero.card.pointsLabel')"
              :goal="240"
              :goal-label="`${t('landing.hero.card.progressLabel')} · ${t('landing.hero.card.reward')}`"
            />
          </div>
        </div>
      </div>

      <p
        class="reveal mt-16 text-xs uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        :class="{ 'reveal-visible': isMounted }"
      >
        {{ t('landing.hero.trust') }}
      </p>
    </div>
  </section>
</template>
