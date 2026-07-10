<script setup lang="ts">
import type { FunctionalComponent, HTMLAttributes, VNodeProps } from 'vue'

defineProps<{
  icon: FunctionalComponent<HTMLAttributes & VNodeProps>
  label: string
}>()
</script>

<template>
  <div
    class="flex shrink-0 items-center gap-2.5 rounded-full border border-border bg-surface-raised px-5 py-2.5 text-sm font-medium text-slate-500 transition-colors duration-300 hover:border-brand-300 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
  >
    <component :is="icon" class="h-4.5 w-4.5" />
    {{ label }}
  </div>
</template>
