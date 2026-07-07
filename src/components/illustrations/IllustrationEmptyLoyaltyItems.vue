<script setup lang="ts">
withDefaults(
  defineProps<{
    kind?: 'program' | 'reward'
    size?: number
  }>(),
  { kind: 'program', size: 128 },
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

    <template v-if="kind === 'program'">
      <rect
        x="40"
        y="70"
        width="70"
        height="44"
        rx="10"
        class="fill-brand-200 dark:fill-brand-500/25"
      />
      <rect
        x="50"
        y="58"
        width="70"
        height="44"
        rx="10"
        class="fill-accent-300 dark:fill-accent-500/40"
      />
      <rect x="60" y="46" width="70" height="44" rx="10" class="fill-brand-600" />
      <rect x="72" y="60" width="30" height="6" rx="3" class="fill-white/70" />
      <rect x="72" y="72" width="18" height="10" rx="3" class="fill-white/50" />
    </template>

    <template v-else>
      <rect x="48" y="78" width="64" height="34" rx="6" class="fill-accent-400" />
      <rect x="48" y="68" width="64" height="14" rx="6" class="fill-accent-500" />
      <rect x="76" y="62" width="8" height="50" class="fill-brand-600" />
      <circle cx="80" cy="52" r="10" class="fill-brand-500" />
    </template>
  </svg>
</template>
