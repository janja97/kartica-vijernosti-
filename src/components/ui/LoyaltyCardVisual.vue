<script setup lang="ts">
import { QrCodeIcon } from '@heroicons/vue/24/outline'
import { computed, toRef } from 'vue'

import ProgressRing from '@/components/ui/ProgressRing.vue'
import { useNumberChangeAnimation } from '@/composables/useNumberChangeAnimation'

const GRADIENT_PRESETS = [
  'from-brand-600 to-accent-500',
  'from-accent-500 to-brand-700',
  'from-brand-500 via-brand-600 to-accent-600',
  'from-accent-400 via-brand-500 to-brand-800',
]

function hashSeed(value: string): number {
  let hash = 0
  for (let i = 0; i < value.length; i++) {
    hash = (hash * 31 + value.charCodeAt(i)) >>> 0
  }
  return hash
}

const props = withDefaults(
  defineProps<{
    businessName: string
    programName?: string | null
    value: number
    valueLabel?: string | null
    goal?: number | null
    goalLabel?: string | null
    variant?: 'compact' | 'detail' | 'hero'
    glass?: boolean
    showQrBadge?: boolean
    badgeLabel?: string | null
    backgroundImageUrl?: string | null
    seed?: string | null
  }>(),
  {
    programName: null,
    valueLabel: null,
    goal: null,
    goalLabel: null,
    variant: 'compact',
    glass: false,
    showQrBadge: true,
    badgeLabel: null,
    backgroundImageUrl: null,
    seed: null,
  },
)

const isDetail = computed(() => props.variant === 'detail' || props.variant === 'hero')

const gradientPreset = computed(
  () => GRADIENT_PRESETS[hashSeed(props.seed || props.businessName) % GRADIENT_PRESETS.length],
)

const surfaceClass = computed(() => {
  if (props.backgroundImageUrl) return ''
  return props.glass
    ? 'border border-white/20 bg-gradient-to-br from-brand-600/90 to-accent-500/90 backdrop-blur-xl'
    : `bg-gradient-to-br ${gradientPreset.value}`
})

const backgroundStyle = computed(() =>
  props.backgroundImageUrl
    ? {
        backgroundImage: `url(${props.backgroundImageUrl})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
      }
    : undefined,
)

const shapeClass = computed(() =>
  props.variant === 'compact' ? 'rounded-2xl p-6' : 'rounded-3xl p-8',
)

const ringSize = computed(() => (props.variant === 'compact' ? 44 : 88))

const { isPulsing } = useNumberChangeAnimation(toRef(props, 'value'))
</script>

<template>
  <div
    class="relative overflow-hidden text-white shadow-soft-lg"
    :class="[surfaceClass, shapeClass, variant === 'hero' ? 'animate-float' : '']"
    :style="backgroundStyle"
  >
    <div
      v-if="backgroundImageUrl"
      class="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-slate-950/30 to-slate-950/10"
    />

    <div class="relative">
      <span
        v-if="badgeLabel"
        class="mb-3 inline-flex rounded-full bg-white/15 px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-white/80"
      >
        {{ badgeLabel }}
      </span>

      <div class="flex items-start justify-between gap-3">
        <div class="min-w-0">
          <p v-if="programName" class="truncate text-[11px] uppercase tracking-wide text-white/60">
            {{ programName }}
          </p>
          <p
            class="mt-1 truncate font-display text-lg font-semibold"
            :class="isDetail ? 'text-xl' : ''"
          >
            {{ businessName }}
          </p>
        </div>

        <div
          v-if="showQrBadge"
          class="relative flex h-10 w-10 flex-none items-center justify-center rounded-xl bg-white/15"
        >
          <span
            v-if="variant === 'hero'"
            class="absolute inset-0 -z-10 animate-pulse-soft rounded-xl bg-accent-300"
          />
          <QrCodeIcon class="h-5 w-5" />
        </div>
      </div>

      <div class="mt-6 flex items-end justify-between gap-4">
        <div class="min-w-0">
          <p v-if="valueLabel" class="text-xs text-white/50">{{ valueLabel }}</p>
          <p
            class="font-display font-bold transition-transform duration-300"
            :class="[
              isDetail ? 'text-5xl' : 'text-3xl',
              isPulsing ? 'scale-110 text-accent-300' : 'scale-100',
            ]"
          >
            {{ value }}
          </p>
        </div>

        <div v-if="goal" class="flex flex-none flex-col items-center gap-1">
          <ProgressRing
            :value="value"
            :max="goal"
            :size="ringSize"
            :stroke-width="isDetail ? 7 : 4"
            color="accent"
            track-color="white"
          >
            <span
              class="font-display font-semibold text-white"
              :class="isDetail ? 'text-sm' : 'text-[10px]'"
            >
              {{ Math.min(Math.round((value / goal) * 100), 100) }}%
            </span>
          </ProgressRing>
          <p
            v-if="goalLabel"
            class="max-w-[6rem] text-center text-[10px] leading-tight text-white/60"
          >
            {{ goalLabel }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
