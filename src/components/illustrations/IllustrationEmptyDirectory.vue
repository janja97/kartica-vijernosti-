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
    <rect x="46" y="70" width="20" height="38" class="fill-brand-300 dark:fill-brand-500/30" />
    <rect x="70" y="56" width="20" height="52" class="fill-brand-500" />
    <rect x="94" y="80" width="20" height="28" class="fill-brand-300 dark:fill-brand-500/30" />
    <rect x="76" y="64" width="6" height="6" class="fill-white/70" />
    <rect x="76" y="76" width="6" height="6" class="fill-white/70" />
    <circle cx="104" cy="96" r="16" class="stroke-accent-500" stroke-width="4" fill="none" />
    <path d="M115 107l10 10" class="stroke-accent-500" stroke-width="4" stroke-linecap="round" />
  </svg>
</template>
