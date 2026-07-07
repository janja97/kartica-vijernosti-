<script setup lang="ts">
import {
  ArrowRightStartOnRectangleIcon,
  BellIcon,
  MoonIcon,
  SunIcon,
} from '@heroicons/vue/24/outline'
import { onClickOutside } from '@vueuse/core'
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter } from 'vue-router'

import { authService } from '@/services/auth.service'
import { useUiStore } from '@/stores/ui.store'
import { useAuthStore } from '@/stores/auth.store'

defineProps<{
  title: string
}>()

const { t } = useI18n()
const ui = useUiStore()
const auth = useAuthStore()
const router = useRouter()

const isMenuOpen = ref(false)
const menuRef = ref<HTMLElement | null>(null)
onClickOutside(menuRef, () => {
  isMenuOpen.value = false
})

const email = computed(() => auth.user?.email ?? '')
const initials = computed(() => (email.value ? email.value.slice(0, 2).toUpperCase() : '?'))

async function handleLogout(): Promise<void> {
  isMenuOpen.value = false
  await authService.signOut()
  await router.push('/')
}
</script>

<template>
  <header class="flex h-16 flex-none items-center justify-between border-b border-border px-6">
    <h1 class="text-lg font-semibold text-slate-900 dark:text-white">{{ title }}</h1>

    <div class="flex items-center gap-2">
      <button
        type="button"
        class="rounded-lg p-2 text-slate-500 transition-colors hover:bg-surface-sunken hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100"
        :aria-label="ui.isDark ? 'Light mode' : 'Dark mode'"
        @click="ui.toggleTheme()"
      >
        <SunIcon v-if="ui.isDark" class="h-5 w-5" />
        <MoonIcon v-else class="h-5 w-5" />
      </button>

      <button
        type="button"
        class="relative rounded-lg p-2 text-slate-500 transition-colors hover:bg-surface-sunken hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100"
        aria-label="Notifications"
      >
        <BellIcon class="h-5 w-5" />
        <span class="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-accent-500" />
      </button>

      <div ref="menuRef" class="relative">
        <button
          type="button"
          class="flex h-9 w-9 items-center justify-center rounded-full bg-brand-600 text-sm font-semibold text-white"
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
            class="absolute right-0 top-11 w-56 rounded-xl border border-border bg-surface-raised p-1.5 shadow-lg"
          >
            <p class="truncate px-3 py-2 text-xs text-slate-500 dark:text-slate-400">{{ email }}</p>
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
  </header>
</template>
