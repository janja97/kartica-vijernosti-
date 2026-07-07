import { useDark, useToggle } from '@vueuse/core'
import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

import { DEFAULT_LOCALE, i18n, setLocale, type SupportedLocale } from '@/i18n'

export const useUiStore = defineStore('ui', () => {
  const isDark = useDark({
    storageKey: 'loyalflow-theme',
    selector: 'html',
    valueDark: 'dark',
    valueLight: 'light',
  })
  const toggleDark = useToggle(isDark)

  const locale = computed<SupportedLocale>(() => i18n.global.locale.value as SupportedLocale)

  const isMobileSidebarOpen = ref(false)

  function toggleTheme(): void {
    toggleDark()
  }

  function changeLocale(next: SupportedLocale): void {
    setLocale(next)
  }

  function toggleMobileSidebar(): void {
    isMobileSidebarOpen.value = !isMobileSidebarOpen.value
  }

  function closeMobileSidebar(): void {
    isMobileSidebarOpen.value = false
  }

  return {
    isDark,
    locale,
    defaultLocale: DEFAULT_LOCALE,
    isMobileSidebarOpen,
    toggleTheme,
    changeLocale,
    toggleMobileSidebar,
    closeMobileSidebar,
  }
})
