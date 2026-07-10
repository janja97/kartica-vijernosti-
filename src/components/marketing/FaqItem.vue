<script setup lang="ts">
import { ChevronDownIcon } from '@heroicons/vue/24/outline'
import { ref } from 'vue'

defineProps<{
  question: string
  answer: string
}>()

const isOpen = ref(false)
</script>

<template>
  <div class="border-b border-border py-2">
    <button
      type="button"
      class="flex w-full items-center justify-between gap-4 py-4 text-left"
      :aria-expanded="isOpen"
      @click="isOpen = !isOpen"
    >
      <span class="font-display text-base font-medium text-slate-900 dark:text-white">
        {{ question }}
      </span>
      <ChevronDownIcon
        class="h-5 w-5 shrink-0 text-slate-400 transition-transform duration-300"
        :class="{ 'rotate-180 text-brand-500': isOpen }"
      />
    </button>
    <div
      class="grid transition-all duration-300 ease-in-out"
      :style="{ gridTemplateRows: isOpen ? '1fr' : '0fr' }"
    >
      <div class="overflow-hidden">
        <p class="pb-5 pr-10 text-sm leading-relaxed text-slate-500 dark:text-slate-400">
          {{ answer }}
        </p>
      </div>
    </div>
  </div>
</template>
