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
    <path d="M44 66a8 8 0 0 1 8-8h30l38 38-38 38-38-38V66z" class="fill-accent-400" />
    <circle cx="58" cy="72" r="6" class="fill-white" />
    <path d="M82 58l32 32" class="stroke-brand-600" stroke-width="4" stroke-linecap="round" />
  </svg>
</template>
