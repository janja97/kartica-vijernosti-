<script setup lang="ts">
import { CheckBadgeIcon } from '@heroicons/vue/24/outline'
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import LoyaltyCardVisual from '@/components/ui/LoyaltyCardVisual.vue'
import { useHeroStampAnimation } from '@/composables/useHeroStampAnimation'

const { t } = useI18n()

const isMounted = ref(false)
onMounted(() => {
  requestAnimationFrame(() => {
    isMounted.value = true
  })
})

const BASE_POINTS = 180
const { phase, points, cycleCount, prefersReducedMotion } = useHeroStampAnimation(BASE_POINTS, 40)

const particles = [
  { x: '48px', y: '-14px', delay: '0ms' },
  { x: '40px', y: '30px', delay: '40ms' },
  { x: '4px', y: '50px', delay: '90ms' },
  { x: '-36px', y: '32px', delay: '60ms' },
  { x: '-48px', y: '-12px', delay: '110ms' },
  { x: '-26px', y: '-42px', delay: '70ms' },
  { x: '4px', y: '-54px', delay: '20ms' },
  { x: '32px', y: '-40px', delay: '130ms' },
]
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
              class="btn-ripple rounded-full bg-brand-600 px-7 py-3.5 text-xs font-semibold uppercase tracking-widest text-white shadow-soft-lg transition-all duration-200 hover:-translate-y-0.5 hover:bg-brand-700"
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
          <div class="relative w-full max-w-sm">
            <Transition
              enter-active-class="transition duration-300 ease-out"
              enter-from-class="opacity-0 scale-75"
              enter-to-class="opacity-100 scale-100"
              leave-active-class="transition duration-300 ease-in"
              leave-from-class="opacity-100 scale-100"
              leave-to-class="opacity-0 scale-75"
            >
              <div
                v-if="phase !== 'idle'"
                :key="cycleCount"
                class="absolute -top-9 right-6 z-20 flex h-16 w-16 items-center justify-center rounded-full border-4 border-dashed border-white/70 bg-accent-500 text-white shadow-soft-lg"
                :class="phase === 'falling' ? 'animate-stamp-fall' : 'rotate-[-8deg]'"
              >
                <CheckBadgeIcon class="h-8 w-8" />
              </div>
            </Transition>

            <div
              v-if="phase === 'burst'"
              :key="`particles-${cycleCount}`"
              class="pointer-events-none absolute inset-0 z-10 flex items-center justify-center"
            >
              <span
                v-for="(particle, index) in particles"
                :key="index"
                class="absolute h-2 w-2 animate-particle-burst rounded-full bg-accent-300"
                :style="{
                  '--particle-x': particle.x,
                  '--particle-y': particle.y,
                  animationDelay: particle.delay,
                }"
              />
            </div>

            <div
              class="rounded-3xl"
              :class="{
                'animate-stamp-pop': phase === 'impact' && !prefersReducedMotion,
                'animate-card-glow-pulse': phase === 'glow' && !prefersReducedMotion,
                'shadow-glow-accent': phase === 'glow' && prefersReducedMotion,
              }"
            >
              <LoyaltyCardVisual
                variant="hero"
                glass
                :business-name="t('landing.hero.card.business')"
                :badge-label="t('landing.hero.card.member')"
                :value="points"
                :value-label="t('landing.hero.card.pointsLabel')"
                :goal="240"
                :goal-label="`${t('landing.hero.card.progressLabel')} · ${t('landing.hero.card.reward')}`"
              />
            </div>
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
