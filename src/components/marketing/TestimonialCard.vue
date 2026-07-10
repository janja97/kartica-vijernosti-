<script setup lang="ts">
defineProps<{
  quote: string
  name: string
  role: string
  initials: string
}>()
</script>

<template>
  <div
    class="flex h-full flex-col rounded-2xl border border-border bg-surface-raised p-7 shadow-soft transition-all duration-300 hover:-translate-y-1 hover:shadow-soft-lg"
  >
    <svg
      class="h-7 w-7 text-brand-300 dark:text-brand-500/40"
      viewBox="0 0 32 24"
      fill="currentColor"
      aria-hidden="true"
    >
      <path
        d="M9.2 24c-2.4 0-4.3-.8-5.8-2.4C1.9 20 1.2 18 1.2 15.6c0-2.7.8-5.3 2.4-7.8C5.2 5.3 7.4 3 10.2.6L14 4c-2 1.7-3.5 3.3-4.6 4.8-1 1.5-1.6 2.9-1.8 4.2.5-.2 1-.3 1.6-.3 1.7 0 3.1.6 4.2 1.7 1.1 1.1 1.7 2.5 1.7 4.2 0 1.7-.6 3.1-1.7 4.2-1.1 1.1-2.5 1.4-4.2 1.4Zm17.8 0c-2.4 0-4.3-.8-5.8-2.4C19.7 20 19 18 19 15.6c0-2.7.8-5.3 2.4-7.8C23 5.3 25.2 3 28 .6L31.8 4c-2 1.7-3.5 3.3-4.6 4.8-1 1.5-1.6 2.9-1.8 4.2.5-.2 1-.3 1.6-.3 1.7 0 3.1.6 4.2 1.7 1.1 1.1 1.7 2.5 1.7 4.2 0 1.7-.6 3.1-1.7 4.2-1.1 1.1-2.5 1.4-4.2 1.4Z"
      />
    </svg>
    <p class="mt-4 flex-1 text-sm leading-relaxed text-slate-600 dark:text-slate-300">
      {{ quote }}
    </p>
    <div class="mt-6 flex items-center gap-3 border-t border-border pt-5">
      <div
        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-600 text-xs font-semibold text-white"
      >
        {{ initials }}
      </div>
      <div>
        <p class="text-sm font-semibold text-slate-900 dark:text-white">{{ name }}</p>
        <p class="text-xs text-slate-500 dark:text-slate-400">{{ role }}</p>
      </div>
    </div>
  </div>
</template>
