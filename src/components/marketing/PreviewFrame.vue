<script setup lang="ts">
defineProps<{
  url: string
}>()
</script>

<template>
  <div
    class="overflow-hidden rounded-2xl border border-border bg-surface-raised shadow-soft-lg transition-transform duration-500 hover:-translate-y-1"
  >
    <div class="flex items-center gap-1.5 border-b border-border bg-surface-sunken/60 px-4 py-3">
      <span class="h-2.5 w-2.5 rounded-full bg-rose-400/70" />
      <span class="h-2.5 w-2.5 rounded-full bg-amber-400/70" />
      <span class="h-2.5 w-2.5 rounded-full bg-success-500/70" />
      <span class="ml-3 truncate text-xs text-slate-400 dark:text-slate-500">{{ url }}</span>
    </div>
    <div class="p-5 sm:p-6">
      <slot />
    </div>
  </div>
</template>
