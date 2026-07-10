<script setup lang="ts">
import type { FunctionalComponent, HTMLAttributes, VNodeProps } from 'vue'

defineProps<{
  icon: FunctionalComponent<HTMLAttributes & VNodeProps>
  title: string
  description: string
}>()
</script>

<template>
  <div
    class="group rounded-2xl border border-border bg-surface-raised p-6 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-soft-lg"
  >
    <div
      class="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-50 text-brand-600 transition-colors duration-300 group-hover:bg-brand-600 group-hover:text-white dark:bg-brand-500/10 dark:text-brand-400"
    >
      <component :is="icon" class="h-5.5 w-5.5" />
    </div>
    <h3 class="mt-5 font-display text-base font-semibold text-slate-900 dark:text-white">
      {{ title }}
    </h3>
    <p class="mt-2 text-sm leading-relaxed text-slate-500 dark:text-slate-400">
      {{ description }}
    </p>
  </div>
</template>
