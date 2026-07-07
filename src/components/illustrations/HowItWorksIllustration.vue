<script setup lang="ts">
withDefaults(
  defineProps<{
    variant: 'signup' | 'card' | 'scan' | 'reward'
    size?: number
  }>(),
  { size: 96 },
)
</script>

<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 160 160"
    fill="none"
    aria-hidden="true"
    class="mx-auto"
  >
    <circle cx="80" cy="80" r="72" class="fill-brand-50 dark:fill-brand-500/10" />

    <template v-if="variant === 'signup'">
      <rect
        x="44"
        y="52"
        width="72"
        height="56"
        rx="12"
        class="fill-white dark:fill-surface-raised"
      />
      <rect
        x="44"
        y="52"
        width="72"
        height="56"
        rx="12"
        class="stroke-border"
        stroke-width="2"
        fill="none"
      />
      <circle cx="68" cy="76" r="10" class="fill-brand-500" />
      <rect x="84" y="70" width="20" height="5" rx="2.5" class="fill-accent-400" />
      <rect x="84" y="80" width="14" height="5" rx="2.5" class="fill-border" />
      <circle cx="112" cy="102" r="12" class="fill-success-500" />
      <path
        d="M107 102l3.5 3.5L117 98"
        class="stroke-white"
        stroke-width="2.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
      />
    </template>

    <template v-else-if="variant === 'card'">
      <rect x="38" y="58" width="84" height="52" rx="14" class="fill-brand-600" />
      <rect x="38" y="58" width="84" height="52" rx="14" fill="url(#cardgrad)" opacity="0.9" />
      <rect x="50" y="70" width="26" height="6" rx="3" class="fill-white/70" />
      <rect x="50" y="82" width="18" height="10" rx="2" class="fill-accent-300" />
      <rect x="96" y="80" width="14" height="14" rx="3" class="fill-white/80" />
      <defs>
        <linearGradient
          id="cardgrad"
          x1="38"
          y1="58"
          x2="122"
          y2="110"
          gradientUnits="userSpaceOnUse"
        >
          <stop stop-color="#4F46E5" />
          <stop offset="1" stop-color="#22D3EE" />
        </linearGradient>
      </defs>
    </template>

    <template v-else-if="variant === 'scan'">
      <rect
        x="46"
        y="46"
        width="68"
        height="68"
        rx="16"
        class="fill-white dark:fill-surface-raised stroke-border"
        stroke-width="2"
      />
      <path
        d="M56 62v-6a4 4 0 0 1 4-4h6"
        class="stroke-accent-500"
        stroke-width="4"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M104 62v-6a4 4 0 0 0-4-4h-6"
        class="stroke-accent-500"
        stroke-width="4"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M56 98v6a4 4 0 0 0 4 4h6"
        class="stroke-accent-500"
        stroke-width="4"
        stroke-linecap="round"
        fill="none"
      />
      <path
        d="M104 98v6a4 4 0 0 1-4 4h-6"
        class="stroke-accent-500"
        stroke-width="4"
        stroke-linecap="round"
        fill="none"
      />
      <rect
        x="66"
        y="66"
        width="28"
        height="28"
        rx="4"
        class="fill-brand-100 dark:fill-brand-500/20"
      />
      <rect x="72" y="72" width="6" height="6" class="fill-brand-600" />
      <rect x="82" y="72" width="6" height="6" class="fill-brand-600" />
      <rect x="72" y="82" width="6" height="6" class="fill-brand-600" />
      <rect x="82" y="82" width="6" height="6" class="fill-accent-500" />
    </template>

    <template v-else>
      <rect x="48" y="76" width="64" height="34" rx="6" class="fill-accent-400" />
      <rect x="48" y="66" width="64" height="14" rx="6" class="fill-accent-500" />
      <rect x="76" y="60" width="8" height="50" class="fill-brand-600" />
      <path
        d="M80 60c-6 0-10-6-10-11s10-1 10 3c0-4 10-8 10-3s-4 11-10 11z"
        class="fill-brand-500"
      />
      <circle cx="46" cy="58" r="4" class="fill-accent-300" />
      <circle cx="116" cy="64" r="3" class="fill-brand-400" />
      <circle cx="112" cy="48" r="2.5" class="fill-accent-400" />
    </template>
  </svg>
</template>
