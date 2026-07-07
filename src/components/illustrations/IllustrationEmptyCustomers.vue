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
    <circle cx="58" cy="66" r="16" class="fill-brand-200 dark:fill-brand-500/30" />
    <path d="M34 112c0-14 11-22 24-22s24 8 24 22" class="fill-brand-200 dark:fill-brand-500/30" />
    <circle cx="100" cy="60" r="20" class="fill-brand-500" />
    <path d="M70 118c0-17 13-27 30-27s30 10 30 27" class="fill-brand-500" />
    <circle cx="100" cy="60" r="20" class="stroke-white/50" stroke-width="2" fill="none" />
  </svg>
</template>
