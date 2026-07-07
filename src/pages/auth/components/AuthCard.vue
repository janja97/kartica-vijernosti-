<script setup lang="ts">
defineProps<{
  title: string
  subtitle?: string
}>()
</script>

<template>
  <div class="reveal reveal-visible w-full max-w-md">
    <div
      class="card-glass relative overflow-hidden rounded-2xl bg-surface-raised/90 p-8 shadow-soft-lg"
    >
      <div class="flex flex-col items-center text-center">
        <RouterLink to="/" class="flex items-center gap-2 font-semibold tracking-tight">
          <span
            class="flex h-8 w-8 items-center justify-center rounded-lg bg-brand-600 text-sm text-white"
          >
            L
          </span>
          <span class="text-lg">LoyalFlow</span>
        </RouterLink>

        <h1 class="mt-6 text-2xl font-semibold tracking-tight text-slate-900 dark:text-white">
          {{ title }}
        </h1>
        <p v-if="subtitle" class="mt-2 text-sm text-slate-500 dark:text-slate-400">
          {{ subtitle }}
        </p>
      </div>

      <div class="mt-8">
        <slot />
      </div>

      <div v-if="$slots.footer" class="mt-6 text-center text-sm text-slate-500 dark:text-slate-400">
        <slot name="footer" />
      </div>
    </div>
  </div>
</template>
