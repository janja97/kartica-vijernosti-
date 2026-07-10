<script setup lang="ts">
import { BellIcon, DevicePhoneMobileIcon, GiftIcon, QrCodeIcon } from '@heroicons/vue/24/outline'
import { useI18n } from 'vue-i18n'

import { useReveal } from '@/pages/landing/composables/useReveal'

interface AudienceFeature {
  title: string
  description: string
}

const icons = [DevicePhoneMobileIcon, QrCodeIcon, BellIcon, GiftIcon]

const { t, tm } = useI18n()
const { target, isVisible } = useReveal()

const items = tm('landing.forCustomers.items') as AudienceFeature[]
</script>

<template>
  <section id="for-customers" ref="target" class="py-28">
    <div class="mx-auto max-w-6xl px-6">
      <div class="reveal max-w-xl" :class="{ 'reveal-visible': isVisible }">
        <p
          class="flex items-center gap-3 text-xs font-medium uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400"
        >
          <span class="h-px w-8 bg-accent-500" />
          {{ t('landing.forCustomers.eyebrow') }}
        </p>
        <h2
          class="mt-6 font-display text-4xl font-semibold leading-tight text-slate-900 dark:text-white sm:text-5xl"
        >
          {{ t('landing.forCustomers.title') }}
        </h2>
        <p class="mt-6 text-base leading-relaxed text-slate-500 dark:text-slate-400">
          {{ t('landing.forCustomers.subtitle') }}
        </p>
      </div>

      <div class="mt-16 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
        <div
          v-for="(item, index) in items"
          :key="item.title"
          class="reveal"
          :class="{ 'reveal-visible': isVisible }"
          :style="{ transitionDelay: isVisible ? `${index * 70}ms` : '0ms' }"
        >
          <div
            class="flex h-11 w-11 items-center justify-center rounded-xl bg-accent-500 text-white"
          >
            <component :is="icons[index]" class="h-5.5 w-5.5" />
          </div>
          <h3 class="mt-5 font-display text-base font-semibold text-slate-900 dark:text-white">
            {{ item.title }}
          </h3>
          <p class="mt-2 text-sm leading-relaxed text-slate-500 dark:text-slate-400">
            {{ item.description }}
          </p>
        </div>
      </div>
    </div>
  </section>
</template>
