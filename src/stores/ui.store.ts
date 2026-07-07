import { useDark, useToggle } from '@vueuse/core'
import { defineStore } from 'pinia'
import { computed } from 'vue'

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

  function toggleTheme(): void {
    toggleDark()
  }

  function changeLocale(next: SupportedLocale): void {
    setLocale(next)
  }

  return {
    isDark,
    locale,
    defaultLocale: DEFAULT_LOCALE,
    toggleTheme,
    changeLocale,
  }
})
