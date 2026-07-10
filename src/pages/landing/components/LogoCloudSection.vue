<script setup lang="ts">
import {
  BoltIcon,
  BuildingStorefrontIcon,
  CakeIcon,
  HomeModernIcon,
  ScissorsIcon,
  SparklesIcon,
  SunIcon,
  TruckIcon,
} from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import LogoChip from '@/components/marketing/LogoChip.vue'

const { t } = useI18n()

const industries = [
  { icon: CakeIcon, key: 'cafes' },
  { icon: BuildingStorefrontIcon, key: 'restaurants' },
  { icon: ScissorsIcon, key: 'salons' },
  { icon: SparklesIcon, key: 'beauty' },
  { icon: BoltIcon, key: 'gyms' },
  { icon: TruckIcon, key: 'carwash' },
  { icon: HomeModernIcon, key: 'hotels' },
  { icon: SunIcon, key: 'wellness' },
]
</script>

<template>
  <section class="border-y border-border bg-surface-raised py-12">
    <p
      class="mx-auto mb-8 max-w-6xl px-6 text-center text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
    >
      {{ t('landing.logoCloud.title') }}
    </p>

    <div class="mask-fade-x overflow-hidden">
      <div class="flex w-max animate-marquee gap-3 hover:[animation-play-state:paused]">
        <LogoChip
          v-for="(item, index) in [...industries, ...industries]"
          :key="index"
          :icon="item.icon"
          :label="t(`landing.logoCloud.industries.${item.key}`)"
        />
      </div>
    </div>
  </section>
</template>
