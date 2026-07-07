<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

const emit = defineEmits<{
  save: [string]
}>()

const { t } = useI18n()

const newPassword = ref('')
const confirmPassword = ref('')
const validationError = ref('')

function handleSubmit(): void {
  validationError.value = ''

  if (newPassword.value.length < 8) {
    validationError.value = t('dashboard.settings.password.tooShort')
    return
  }
  if (newPassword.value !== confirmPassword.value) {
    validationError.value = t('dashboard.settings.password.mismatch')
    return
  }

  emit('save', newPassword.value)
  newPassword.value = ''
  confirmPassword.value = ''
}
</script>

<template>
  <form
    class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
    @submit.prevent="handleSubmit"
  >
    <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
      {{ t('dashboard.settings.password.title') }}
    </h2>

    <div class="grid gap-4 sm:grid-cols-2">
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.password.newPassword') }}
        </label>
        <input
          v-model="newPassword"
          type="password"
          autocomplete="new-password"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.password.confirmPassword') }}
        </label>
        <input
          v-model="confirmPassword"
          type="password"
          autocomplete="new-password"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>
    </div>

    <p v-if="validationError" class="text-sm text-rose-600 dark:text-rose-400">
      {{ validationError }}
    </p>

    <button
      type="submit"
      class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
    >
      {{ t('dashboard.settings.password.submit') }}
    </button>
  </form>
</template>
