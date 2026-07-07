<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const year = new Date().getFullYear()
</script>

<template>
  <footer class="border-t border-border">
    <div class="mx-auto max-w-6xl px-6 py-14">
      <div class="flex flex-col gap-10 sm:flex-row sm:justify-between">
        <div class="max-w-xs">
          <p
            class="font-display text-xl font-semibold tracking-tight text-slate-900 dark:text-white"
          >
            Loyal<span class="text-accent-500">Flow</span>
          </p>
          <p class="mt-3 text-sm text-slate-500 dark:text-slate-400">
            {{ t('landing.footer.tagline') }}
          </p>
        </div>

        <div class="grid grid-cols-2 gap-10 sm:gap-16">
          <div>
            <h3
              class="text-xs font-medium uppercase tracking-widest text-slate-900 dark:text-white"
            >
              {{ t('landing.footer.product') }}
            </h3>
            <ul class="mt-4 space-y-2 text-sm text-slate-500 dark:text-slate-400">
              <li>
                <a href="#benefits" class="hover:text-accent-500">{{
                  t('landing.nav.benefits')
                }}</a>
              </li>
              <li>
                <a href="#how-it-works" class="hover:text-accent-500">{{
                  t('landing.nav.howItWorks')
                }}</a>
              </li>
            </ul>
          </div>

          <div>
            <h3
              class="text-xs font-medium uppercase tracking-widest text-slate-900 dark:text-white"
            >
              {{ t('landing.footer.company') }}
            </h3>
            <ul class="mt-4 space-y-2 text-sm text-slate-500 dark:text-slate-400">
              <li>
                <a href="mailto:hello@loyalflow.app" class="hover:text-accent-500">{{
                  t('landing.footer.contact')
                }}</a>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div
        class="mt-14 flex flex-col items-center justify-between gap-4 border-t border-border pt-6 text-xs uppercase tracking-widest text-slate-500 dark:text-slate-400 sm:flex-row"
      >
        <p>© {{ year }} {{ t('app.name') }}. {{ t('landing.footer.rights') }}</p>
        <p class="normal-case tracking-normal">
          {{ t('landing.footer.madeFor') }}
        </p>
      </div>
    </div>
  </footer>
</template>
