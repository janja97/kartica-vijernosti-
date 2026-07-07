<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import type { PromoCode } from '@/types/domain/marketing.types'

const props = defineProps<{
  promoCode: PromoCode
}>()

const emit = defineEmits<{
  toggleActive: []
}>()

const { t } = useI18n()

const discountLabel = computed(() => {
  if (props.promoCode.discountPercent !== null) return `-${props.promoCode.discountPercent}%`
  if (props.promoCode.discountAmount !== null) return `-${props.promoCode.discountAmount}`
  return ''
})
</script>

<template>
  <div
    class="flex items-center justify-between rounded-2xl border border-border bg-surface-raised p-5 shadow-soft"
  >
    <div>
      <div class="flex items-center gap-2">
        <h3 class="font-mono text-base font-semibold text-slate-900 dark:text-white">
          {{ promoCode.code }}
        </h3>
        <span
          v-if="discountLabel"
          class="rounded-full bg-accent-50 px-2 py-0.5 text-xs font-semibold text-accent-700 dark:bg-accent-500/10 dark:text-accent-400"
        >
          {{ discountLabel }}
        </span>
        <span
          v-if="!promoCode.isActive"
          class="rounded-full bg-surface-sunken px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-slate-400"
        >
          {{ t('dashboard.programs.inactiveLabel') }}
        </span>
      </div>
      <p v-if="promoCode.description" class="mt-1 text-sm text-slate-500 dark:text-slate-400">
        {{ promoCode.description }}
      </p>
      <p class="mt-1 text-xs text-slate-400 dark:text-slate-500">
        {{ t('dashboard.marketing.promoCodes.redeemedCount', { n: promoCode.timesRedeemed }) }}
        <template v-if="promoCode.maxRedemptions"> / {{ promoCode.maxRedemptions }}</template>
      </p>
    </div>

    <button
      type="button"
      class="flex-none rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
      @click="emit('toggleActive')"
    >
      {{ promoCode.isActive ? t('dashboard.rewards.deactivate') : t('dashboard.rewards.activate') }}
    </button>
  </div>
</template>
