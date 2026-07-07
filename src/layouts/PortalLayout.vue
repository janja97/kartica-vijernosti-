<script setup lang="ts">
import {
  ArrowRightStartOnRectangleIcon,
  MoonIcon,
  QrCodeIcon,
  SunIcon,
  XMarkIcon,
} from '@heroicons/vue/24/outline'
import { onClickOutside } from '@vueuse/core'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import QrCodeDisplay from '@/pages/portal/card-detail/components/QrCodeDisplay.vue'
import { useMyCards } from '@/pages/portal/my-cards/composables/useMyCards'
import { authService } from '@/services/auth.service'
import { useAuthStore } from '@/stores/auth.store'
import { useUiStore } from '@/stores/ui.store'

const { t } = useI18n()
const ui = useUiStore()
const auth = useAuthStore()
const router = useRouter()

const isMenuOpen = ref(false)
const menuRef = ref<HTMLElement | null>(null)
onClickOutside(menuRef, () => {
  isMenuOpen.value = false
})

const { data: cards } = useMyCards()
const primaryCard = computed(() => cards.value?.[0] ?? null)
const isQrModalOpen = ref(false)

const email = computed(() => auth.user?.email ?? '')
const initials = computed(() => (email.value ? email.value.slice(0, 2).toUpperCase() : '?'))

async function handleLogout(): Promise<void> {
  isMenuOpen.value = false
  await authService.signOut()
  await router.push('/')
}
</script>

<template>
  <div class="min-h-screen bg-surface-sunken">
    <header class="sticky top-0 z-40 border-b border-border bg-surface/90 backdrop-blur-md">
      <div class="mx-auto flex h-16 max-w-5xl items-center justify-between px-6">
        <RouterLink
          to="/app"
          class="flex items-center gap-2 font-display font-semibold tracking-tight"
        >
          <span
            class="flex h-7 w-7 items-center justify-center rounded-lg bg-gradient-to-br from-brand-600 to-accent-500 text-sm text-white"
          >
            L
          </span>
          LoyalFlow
        </RouterLink>

        <nav
          class="hidden items-center gap-6 text-sm font-medium text-slate-600 dark:text-slate-300 sm:flex"
        >
          <RouterLink
            to="/app/businesses"
            class="transition-colors hover:text-brand-600 dark:hover:text-brand-400"
          >
            {{ t('portal.nav.businesses') }}
          </RouterLink>
          <RouterLink
            to="/app"
            class="transition-colors hover:text-brand-600 dark:hover:text-brand-400"
          >
            {{ t('portal.nav.myCards') }}
          </RouterLink>
        </nav>

        <div class="flex items-center gap-2">
          <button
            v-if="primaryCard"
            type="button"
            class="rounded-lg p-2 text-slate-500 transition-colors hover:bg-surface-sunken hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100"
            :aria-label="t('portal.cardDetail.qrTitle')"
            @click="isQrModalOpen = true"
          >
            <QrCodeIcon class="h-5 w-5" />
          </button>

          <button
            type="button"
            class="rounded-lg p-2 text-slate-500 transition-colors hover:bg-surface-sunken hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100"
            :aria-label="ui.isDark ? 'Light mode' : 'Dark mode'"
            @click="ui.toggleTheme()"
          >
            <SunIcon v-if="ui.isDark" class="h-5 w-5" />
            <MoonIcon v-else class="h-5 w-5" />
          </button>

          <div ref="menuRef" class="relative">
            <button
              type="button"
              class="flex h-9 w-9 items-center justify-center rounded-full bg-gradient-to-br from-brand-600 to-accent-500 text-sm font-semibold text-white"
              @click="isMenuOpen = !isMenuOpen"
            >
              {{ initials }}
            </button>

            <Transition
              enter-active-class="transition duration-150 ease-out"
              enter-from-class="opacity-0 scale-95"
              enter-to-class="opacity-100 scale-100"
              leave-active-class="transition duration-100 ease-in"
              leave-from-class="opacity-100 scale-100"
              leave-to-class="opacity-0 scale-95"
            >
              <div
                v-if="isMenuOpen"
                class="absolute right-0 top-11 w-56 rounded-xl border border-border bg-surface-raised p-1.5 shadow-soft-lg"
              >
                <p class="truncate px-3 py-2 text-xs text-slate-500 dark:text-slate-400">
                  {{ email }}
                </p>
                <button
                  type="button"
                  class="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
                  @click="handleLogout"
                >
                  <ArrowRightStartOnRectangleIcon class="h-4 w-4" />
                  {{ t('dashboard.topbar.logout') }}
                </button>
              </div>
            </Transition>
          </div>
        </div>
      </div>

      <nav
        class="flex items-center gap-4 border-t border-border px-6 py-2 text-sm font-medium text-slate-600 dark:text-slate-300 sm:hidden"
      >
        <RouterLink to="/app/businesses" class="hover:text-brand-600 dark:hover:text-brand-400">
          {{ t('portal.nav.businesses') }}
        </RouterLink>
        <RouterLink to="/app" class="hover:text-brand-600 dark:hover:text-brand-400">
          {{ t('portal.nav.myCards') }}
        </RouterLink>
      </nav>
    </header>

    <main class="mx-auto max-w-5xl px-6 py-8">
      <RouterView />
    </main>

    <Transition
      enter-active-class="transition duration-150 ease-out"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="isQrModalOpen && primaryCard"
        class="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/60 p-4 backdrop-blur-sm"
        @click.self="isQrModalOpen = false"
      >
        <div class="w-full max-w-xs rounded-3xl bg-surface-raised p-6 text-center shadow-soft-lg">
          <div class="flex items-center justify-between">
            <p class="font-display text-sm font-semibold text-slate-900 dark:text-white">
              {{ primaryCard.businessName }}
            </p>
            <button
              type="button"
              class="rounded-lg p-1 text-slate-400 hover:text-slate-900 dark:hover:text-white"
              aria-label="Close"
              @click="isQrModalOpen = false"
            >
              <XMarkIcon class="h-5 w-5" />
            </button>
          </div>
          <div class="mt-4 flex justify-center">
            <QrCodeDisplay :value="primaryCard.qrCode" />
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>
