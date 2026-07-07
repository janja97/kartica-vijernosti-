<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { Profile, ProfileUpdateInput } from '@/types/domain/profile.types'

const props = defineProps<{
  profile: Profile
  isSaving: boolean
}>()

const emit = defineEmits<{
  save: [ProfileUpdateInput]
}>()

const { t } = useI18n()

const firstName = ref(props.profile.firstName ?? '')
const lastName = ref(props.profile.lastName ?? '')
const phone = ref(props.profile.phone ?? '')
const dateOfBirth = ref(props.profile.dateOfBirth ?? '')

function handleSubmit(): void {
  emit('save', {
    firstName: firstName.value || null,
    lastName: lastName.value || null,
    phone: phone.value || null,
    dateOfBirth: dateOfBirth.value || null,
  })
}
</script>

<template>
  <form
    class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
    @submit.prevent="handleSubmit"
  >
    <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
      {{ t('dashboard.settings.profile.title') }}
    </h2>

    <div>
      <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
        {{ t('auth.fields.email') }}
      </label>
      <input
        :value="profile.email"
        type="email"
        disabled
        class="w-full cursor-not-allowed rounded-lg border border-border bg-surface-sunken px-3.5 py-2.5 text-sm text-slate-500 dark:text-slate-400"
      />
    </div>

    <div class="grid gap-4 sm:grid-cols-2">
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('auth.fields.firstName') }}
        </label>
        <input
          v-model="firstName"
          type="text"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('auth.fields.lastName') }}
        </label>
        <input
          v-model="lastName"
          type="text"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.profile.phone') }}
        </label>
        <input
          v-model="phone"
          type="tel"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.profile.dateOfBirth') }}
        </label>
        <input
          v-model="dateOfBirth"
          type="date"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>
    </div>

    <button
      type="submit"
      :disabled="isSaving"
      class="rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700 disabled:cursor-not-allowed disabled:opacity-60"
    >
      {{ isSaving ? t('common.loading') : t('dashboard.settings.saveButton') }}
    </button>
  </form>
</template>
