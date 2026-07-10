<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const year = new Date().getFullYear()
</script>

<template>
  <footer class="border-t border-border">
    <div class="mx-auto max-w-6xl px-6 py-16">
      <div class="grid gap-12 sm:grid-cols-2 lg:grid-cols-[1.3fr_0.7fr_0.7fr_1fr]">
        <div class="max-w-xs">
          <p
            class="font-display text-xl font-semibold tracking-tight text-slate-900 dark:text-white"
          >
            Loyal<span class="text-accent-500">Flow</span>
          </p>
          <p class="mt-3 text-sm text-slate-500 dark:text-slate-400">
            {{ t('landing.footer.tagline') }}
          </p>

          <div class="mt-5 flex items-center gap-3">
            <a
              href="#"
              aria-label="X"
              class="flex h-9 w-9 items-center justify-center rounded-full border border-border text-slate-500 transition-colors hover:border-brand-300 hover:text-brand-600 dark:text-slate-400"
            >
              <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path
                  d="M18.9 2H22l-7.5 8.6L23 22h-6.9l-5.4-6.8L4.5 22H1.4l8-9.2L1 2h7.1l4.9 6.2L18.9 2Zm-1.2 18h1.9L6.4 3.9H4.4L17.7 20Z"
                />
              </svg>
            </a>
            <a
              href="#"
              aria-label="Instagram"
              class="flex h-9 w-9 items-center justify-center rounded-full border border-border text-slate-500 transition-colors hover:border-brand-300 hover:text-brand-600 dark:text-slate-400"
            >
              <svg
                class="h-4 w-4"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                aria-hidden="true"
              >
                <rect x="3" y="3" width="18" height="18" rx="5" />
                <circle cx="12" cy="12" r="4" />
                <circle cx="17.2" cy="6.8" r="0.9" fill="currentColor" stroke="none" />
              </svg>
            </a>
            <a
              href="#"
              aria-label="LinkedIn"
              class="flex h-9 w-9 items-center justify-center rounded-full border border-border text-slate-500 transition-colors hover:border-brand-300 hover:text-brand-600 dark:text-slate-400"
            >
              <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path
                  d="M4.98 3.5a2 2 0 1 1 0 4 2 2 0 0 1 0-4ZM3 9h4v12H3V9Zm7 0h3.8v1.7h.05c.53-.95 1.83-1.96 3.77-1.96 4.03 0 4.78 2.53 4.78 5.82V21h-4v-5.6c0-1.34-.02-3.05-1.86-3.05-1.87 0-2.15 1.44-2.15 2.95V21h-4V9Z"
                />
              </svg>
            </a>
          </div>
        </div>

        <div>
          <h3 class="text-xs font-medium uppercase tracking-widest text-slate-900 dark:text-white">
            {{ t('landing.footer.product') }}
          </h3>
          <ul class="mt-4 space-y-2 text-sm text-slate-500 dark:text-slate-400">
            <li>
              <a href="#why" class="hover:text-accent-500">{{ t('landing.nav.why') }}</a>
            </li>
            <li>
              <a href="#how-it-works" class="hover:text-accent-500">{{
                t('landing.nav.howItWorks')
              }}</a>
            </li>
            <li>
              <a href="#features" class="hover:text-accent-500">{{ t('landing.nav.features') }}</a>
            </li>
            <li>
              <a href="#faq" class="hover:text-accent-500">{{ t('landing.nav.faq') }}</a>
            </li>
          </ul>
        </div>

        <div>
          <h3 class="text-xs font-medium uppercase tracking-widest text-slate-900 dark:text-white">
            {{ t('landing.footer.company') }}
          </h3>
          <ul class="mt-4 space-y-2 text-sm text-slate-500 dark:text-slate-400">
            <li>
              <a href="mailto:hello@loyalflow.app" class="hover:text-accent-500">{{
                t('landing.footer.contact')
              }}</a>
            </li>
            <li>
              <RouterLink to="/auth/login" class="hover:text-accent-500">{{
                t('landing.nav.login')
              }}</RouterLink>
            </li>
            <li>
              <RouterLink to="/auth/register" class="hover:text-accent-500">{{
                t('landing.nav.cta')
              }}</RouterLink>
            </li>
          </ul>
        </div>

        <div>
          <h3 class="text-xs font-medium uppercase tracking-widest text-slate-900 dark:text-white">
            {{ t('landing.footer.newsletterTitle') }}
          </h3>
          <p class="mt-4 text-sm text-slate-500 dark:text-slate-400">
            {{ t('landing.footer.newsletterSubtitle') }}
          </p>
          <form class="mt-4 flex gap-2" @submit.prevent>
            <input
              type="email"
              autocomplete="email"
              placeholder="ime@example.com"
              class="focus-glow min-w-0 flex-1 rounded-lg border border-border bg-surface-raised px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 dark:text-white"
            />
            <button
              type="submit"
              class="btn-ripple flex-none rounded-lg bg-brand-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-brand-700"
            >
              {{ t('landing.footer.newsletterButton') }}
            </button>
          </form>
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
