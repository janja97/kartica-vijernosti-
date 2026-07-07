<script setup lang="ts">
withDefaults(defineProps<{ size?: number }>(), { size: 128 })
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
    <rect
      x="40"
      y="58"
      width="80"
      height="50"
      rx="14"
      class="stroke-brand-300 dark:stroke-brand-500/40"
      stroke-width="3"
      stroke-dasharray="6 7"
      fill="none"
    />
    <circle cx="60" cy="83" r="4" class="fill-accent-400" />
    <rect
      x="72"
      y="80"
      width="24"
      height="6"
      rx="3"
      class="fill-brand-200 dark:fill-brand-500/30"
    />
  </svg>
</template>
