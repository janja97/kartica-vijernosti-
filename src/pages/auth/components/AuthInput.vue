<script setup lang="ts">
import { useId } from 'vue'

withDefaults(
  defineProps<{
    label: string
    type?: string
    placeholder?: string
    autocomplete?: string
  }>(),
  {
    type: 'text',
    placeholder: '',
    autocomplete: 'off',
  },
)

const model = defineModel<string>({ default: '' })

const inputId = useId()
</script>

<template>
  <div>
    <label
      :for="inputId"
      class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300"
    >
      {{ label }}
    </label>
    <input
      :id="inputId"
      v-model="model"
      :type="type"
      :placeholder="placeholder"
      :autocomplete="autocomplete"
      class="focus-glow w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none transition-all placeholder:text-slate-400 dark:text-white"
    />
  </div>
</template>
