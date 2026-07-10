<script setup lang="ts">
import { Bars3Icon, MoonIcon, SunIcon, XMarkIcon } from '@heroicons/vue/24/outline'
import { useScroll } from '@vueuse/core'
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import { useUiStore } from '@/stores/ui.store'

const { t } = useI18n()
const ui = useUiStore()

const { y } = useScroll(window)
const isMobileMenuOpen = ref(false)

function toggleLocale(): void {
  ui.changeLocale(ui.locale === 'hr' ? 'en' : 'hr')
}

function closeMobileMenu(): void {
  isMobileMenuOpen.value = false
}
</script>

<template>
  <header
    class="sticky top-0 z-40 border-b bg-surface/90 backdrop-blur-md transition-colors duration-300"
    :class="y > 8 ? 'border-border' : 'border-transparent'"
  >
    <div class="mx-auto flex h-20 max-w-6xl items-center justify-between px-6">
      <a
        href="#"
        class="font-display text-2xl font-semibold tracking-tight text-slate-900 dark:text-white"
      >
        Loyal<span class="text-accent-500">Flow</span>
      </a>

      <nav
        class="hidden items-center gap-10 text-xs font-medium uppercase tracking-widest text-slate-500 dark:text-slate-400 md:flex"
      >
        <a href="#why" class="transition-colors hover:text-slate-900 dark:hover:text-white">
          {{ t('landing.nav.why') }}
        </a>
        <a
          href="#how-it-works"
          class="transition-colors hover:text-slate-900 dark:hover:text-white"
        >
          {{ t('landing.nav.howItWorks') }}
        </a>
        <a href="#features" class="transition-colors hover:text-slate-900 dark:hover:text-white">
          {{ t('landing.nav.features') }}
        </a>
        <a href="#faq" class="transition-colors hover:text-slate-900 dark:hover:text-white">
          {{ t('landing.nav.faq') }}
        </a>
      </nav>

      <div class="flex items-center gap-1">
        <button
          type="button"
          class="hidden rounded-md px-2 py-1.5 text-xs font-medium uppercase tracking-widest text-slate-500 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white sm:inline-block"
          @click="toggleLocale"
        >
          {{ ui.locale.toUpperCase() }}
        </button>

        <button
          type="button"
          class="rounded-md p-2 text-slate-500 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
          :aria-label="ui.isDark ? 'Light mode' : 'Dark mode'"
          @click="ui.toggleTheme()"
        >
          <SunIcon v-if="ui.isDark" class="h-4.5 w-4.5" />
          <MoonIcon v-else class="h-4.5 w-4.5" />
        </button>

        <RouterLink
          to="/auth/login"
          class="hidden rounded-md px-3 py-2 text-xs font-medium uppercase tracking-widest text-slate-500 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white sm:inline-block"
        >
          {{ t('landing.nav.login') }}
        </RouterLink>

        <RouterLink
          to="/auth/register"
          class="btn-ripple hidden items-center gap-2 rounded-full bg-brand-600 px-5 py-2.5 text-xs font-semibold uppercase tracking-widest text-white shadow-soft transition-all duration-200 hover:-translate-y-0.5 hover:bg-brand-700 sm:inline-flex"
        >
          {{ t('landing.nav.cta') }}
        </RouterLink>

        <button
          type="button"
          class="rounded-md p-2 text-slate-500 dark:text-slate-400 md:hidden"
          aria-label="Menu"
          @click="isMobileMenuOpen = !isMobileMenuOpen"
        >
          <XMarkIcon v-if="isMobileMenuOpen" class="h-6 w-6" />
          <Bars3Icon v-else class="h-6 w-6" />
        </button>
      </div>
    </div>

    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div v-if="isMobileMenuOpen" class="border-t border-border bg-surface px-6 py-4 md:hidden">
        <nav class="flex flex-col gap-1 text-sm font-medium text-slate-500 dark:text-slate-400">
          <a
            href="#why"
            class="rounded-md px-2 py-2 hover:bg-surface-sunken"
            @click="closeMobileMenu"
          >
            {{ t('landing.nav.why') }}
          </a>
          <a
            href="#how-it-works"
            class="rounded-md px-2 py-2 hover:bg-surface-sunken"
            @click="closeMobileMenu"
          >
            {{ t('landing.nav.howItWorks') }}
          </a>
          <a
            href="#features"
            class="rounded-md px-2 py-2 hover:bg-surface-sunken"
            @click="closeMobileMenu"
          >
            {{ t('landing.nav.features') }}
          </a>
          <a
            href="#faq"
            class="rounded-md px-2 py-2 hover:bg-surface-sunken"
            @click="closeMobileMenu"
          >
            {{ t('landing.nav.faq') }}
          </a>
          <button
            type="button"
            class="rounded-md px-2 py-2 text-left hover:bg-surface-sunken"
            @click="toggleLocale"
          >
            {{ ui.locale === 'hr' ? 'English' : 'Hrvatski' }}
          </button>
          <RouterLink
            to="/auth/login"
            class="rounded-md px-2 py-2 hover:bg-surface-sunken"
            @click="closeMobileMenu"
          >
            {{ t('landing.nav.login') }}
          </RouterLink>
          <RouterLink
            to="/auth/register"
            class="btn-ripple mt-2 rounded-full bg-brand-600 px-3 py-2 text-center font-semibold text-white"
            @click="closeMobileMenu"
          >
            {{ t('landing.nav.cta') }}
          </RouterLink>
        </nav>
      </div>
    </Transition>
  </header>
</template>
