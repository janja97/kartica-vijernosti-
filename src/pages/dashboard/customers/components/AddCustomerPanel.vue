<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

const emit = defineEmits<{
  save: [{ firstName: string; lastName: string | null; email: string }]
  cancel: []
}>()

const { t } = useI18n()

const firstName = ref('')
const lastName = ref('')
const email = ref('')

function handleSubmit(): void {
  emit('save', {
    firstName: firstName.value,
    lastName: lastName.value || null,
    email: email.value,
  })
}
</script>

<template>
  <form
    class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
    @submit.prevent="handleSubmit"
  >
    <div class="grid gap-4 sm:grid-cols-2">
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.customers.form.firstName') }}
        </label>
        <input
          v-model="firstName"
          type="text"
          required
          class="focus-glow w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none dark:text-white"
        />
      </div>
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.customers.form.lastName') }}
        </label>
        <input
          v-model="lastName"
          type="text"
          class="focus-glow w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none dark:text-white"
        />
      </div>
    </div>

    <div>
      <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
        {{ t('dashboard.customers.form.email') }}
      </label>
      <input
        v-model="email"
        type="email"
        required
        class="focus-glow w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none dark:text-white"
      />
      <p class="mt-1.5 text-xs text-slate-500 dark:text-slate-400">
        {{ t('dashboard.customers.form.emailHint') }}
      </p>
    </div>

    <div class="flex gap-3">
      <button
        type="submit"
        class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
      >
        {{ t('dashboard.customers.form.save') }}
      </button>
      <button
        type="button"
        class="rounded-lg border border-border px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
        @click="emit('cancel')"
      >
        {{ t('dashboard.customers.form.cancel') }}
      </button>
    </div>
  </form>
</template>
