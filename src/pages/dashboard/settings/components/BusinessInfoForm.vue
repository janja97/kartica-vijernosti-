<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import ImageUploadField from '@/components/ui/ImageUploadField.vue'
import { BUSINESS_CATEGORIES } from '@/constants/businessCategories'
import type { Business, BusinessUpdateInput } from '@/types/domain/business.types'
import type { BusinessCategory } from '@/types/database.types'

const props = defineProps<{
  business: Business
  isSaving: boolean
}>()

const emit = defineEmits<{
  save: [BusinessUpdateInput]
  updateLogo: [string | null]
}>()

const { t } = useI18n()

const name = ref(props.business.name)
const category = ref<BusinessCategory>(props.business.category)
const city = ref(props.business.city ?? '')
const addressLine = ref(props.business.addressLine ?? '')
const email = ref(props.business.email ?? '')
const phone = ref(props.business.phone ?? '')
const description = ref(props.business.description ?? '')
const logoUrl = ref(props.business.logoUrl)

function handleSubmit(): void {
  emit('save', {
    name: name.value,
    category: category.value,
    city: city.value || null,
    addressLine: addressLine.value || null,
    email: email.value || null,
    phone: phone.value || null,
    description: description.value || null,
  })
}

function handleLogoChange(url: string | null): void {
  logoUrl.value = url
  emit('updateLogo', url)
}
</script>

<template>
  <form
    class="space-y-4 rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
    @submit.prevent="handleSubmit"
  >
    <h2 class="font-display text-sm font-semibold text-slate-900 dark:text-white">
      {{ t('dashboard.settings.business.title') }}
    </h2>

    <ImageUploadField
      :model-value="logoUrl"
      bucket="business-logos"
      :business-id="business.id"
      file-name="logo"
      :label="t('dashboard.settings.business.logo')"
      @update:model-value="handleLogoChange"
    />

    <div class="grid gap-4 sm:grid-cols-2">
      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('auth.fields.businessName') }}
        </label>
        <input
          v-model="name"
          type="text"
          required
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('auth.fields.category') }}
        </label>
        <select
          v-model="category"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        >
          <option v-for="option in BUSINESS_CATEGORIES" :key="option" :value="option">
            {{ t(`business.categories.${option}`) }}
          </option>
        </select>
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('auth.fields.city') }}
        </label>
        <input
          v-model="city"
          type="text"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.business.address') }}
        </label>
        <input
          v-model="addressLine"
          type="text"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.business.email') }}
        </label>
        <input
          v-model="email"
          type="email"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>

      <div>
        <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
          {{ t('dashboard.settings.business.phone') }}
        </label>
        <input
          v-model="phone"
          type="tel"
          class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
        />
      </div>
    </div>

    <div>
      <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
        {{ t('dashboard.settings.business.description') }}
      </label>
      <textarea
        v-model="description"
        rows="3"
        class="w-full rounded-lg border border-border bg-surface px-3.5 py-2.5 text-sm text-slate-900 shadow-sm outline-none focus:border-brand-500 focus:ring-2 focus:ring-brand-500/20 dark:text-white"
      />
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
