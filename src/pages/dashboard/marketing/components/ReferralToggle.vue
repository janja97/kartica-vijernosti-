<script setup lang="ts">
import { useI18n } from 'vue-i18n'

defineProps<{
  enabled: boolean
  isSaving: boolean
}>()

const emit = defineEmits<{
  toggle: [boolean]
}>()

const { t } = useI18n()
</script>

<template>
  <div
    class="flex items-center justify-between rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
  >
    <div>
      <h2 class="text-sm font-semibold text-slate-900 dark:text-white">
        {{ t('dashboard.marketing.referral.title') }}
      </h2>
      <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
        {{ t('dashboard.marketing.referral.description') }}
      </p>
    </div>
    <label class="flex flex-none items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
      <input
        :checked="enabled"
        type="checkbox"
        :disabled="isSaving"
        class="h-4 w-4 rounded border-border text-brand-600 focus:ring-brand-500/30"
        @change="emit('toggle', ($event.target as HTMLInputElement).checked)"
      />
      {{
        enabled
          ? t('dashboard.marketing.referral.enabled')
          : t('dashboard.marketing.referral.disabled')
      }}
    </label>
  </div>
</template>
