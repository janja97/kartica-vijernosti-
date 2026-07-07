<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    value: number
    max: number
    size?: number
    strokeWidth?: number
    color?: 'brand' | 'accent' | 'success'
    trackColor?: 'border' | 'white'
    showLabel?: boolean
  }>(),
  {
    size: 64,
    strokeWidth: 6,
    color: 'accent',
    trackColor: 'border',
    showLabel: false,
  },
)

const radius = computed(() => (props.size - props.strokeWidth) / 2)
const circumference = computed(() => 2 * Math.PI * radius.value)
const ratio = computed(() =>
  props.max > 0 ? Math.min(Math.max(props.value / props.max, 0), 1) : 0,
)
const dashOffset = computed(() => circumference.value * (1 - ratio.value))

const strokeClass = computed(() => {
  switch (props.color) {
    case 'brand':
      return 'stroke-brand-600'
    case 'success':
      return 'stroke-success-500'
    default:
      return 'stroke-accent-500'
  }
})

const trackClass = computed(() =>
  props.trackColor === 'white' ? 'stroke-white/25' : 'stroke-border',
)
</script>

<template>
  <div
    class="relative inline-flex items-center justify-center"
    :style="{ width: `${size}px`, height: `${size}px` }"
  >
    <svg :width="size" :height="size" class="-rotate-90">
      <circle
        :cx="size / 2"
        :cy="size / 2"
        :r="radius"
        fill="none"
        stroke-linecap="round"
        :class="trackClass"
        :stroke-width="strokeWidth"
      />
      <circle
        :cx="size / 2"
        :cy="size / 2"
        :r="radius"
        fill="none"
        stroke-linecap="round"
        :class="strokeClass"
        :stroke-width="strokeWidth"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="dashOffset"
        style="transition: stroke-dashoffset 0.6s cubic-bezier(0.16, 1, 0.3, 1)"
      />
    </svg>
    <div class="absolute inset-0 flex items-center justify-center">
      <slot>
        <span v-if="showLabel" class="text-xs font-semibold text-slate-700 dark:text-slate-200">
          {{ Math.round(ratio * 100) }}%
        </span>
      </slot>
    </div>
  </div>
</template>
