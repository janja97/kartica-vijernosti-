<script setup lang="ts">
import type { FunctionalComponent, HTMLAttributes, VNodeProps } from 'vue'

defineProps<{
  label: string
  value: number | string
  icon?: FunctionalComponent<HTMLAttributes & VNodeProps>
}>()
</script>

<template>
  <div
    class="rounded-2xl border border-border bg-surface-raised p-5 shadow-soft transition-shadow duration-200 hover:shadow-soft-lg"
  >
    <div class="flex items-start justify-between gap-3">
      <p class="text-sm text-slate-500 dark:text-slate-400">{{ label }}</p>
      <span
        v-if="icon"
        class="flex h-8 w-8 flex-none items-center justify-center rounded-lg bg-accent-50 text-accent-600 dark:bg-accent-500/10 dark:text-accent-400"
      >
        <component :is="icon" class="h-4 w-4" />
      </span>
    </div>
    <p
      class="mt-2 font-display text-2xl font-semibold tracking-tight text-slate-900 dark:text-white"
    >
      {{ value }}
    </p>
  </div>
</template>
