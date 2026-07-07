import { createI18n } from 'vue-i18n'

import en from '@/locales/en.json'
import hr from '@/locales/hr.json'

export const SUPPORTED_LOCALES = ['hr', 'en'] as const
export type SupportedLocale = (typeof SUPPORTED_LOCALES)[number]

export const DEFAULT_LOCALE: SupportedLocale = 'hr'

function detectBrowserLocale(): SupportedLocale {
  const browserLang = navigator.language.slice(0, 2)
  return SUPPORTED_LOCALES.includes(browserLang as SupportedLocale)
    ? (browserLang as SupportedLocale)
    : DEFAULT_LOCALE
}

const STORAGE_KEY = 'loyalflow-locale'

function getInitialLocale(): SupportedLocale {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored && SUPPORTED_LOCALES.includes(stored as SupportedLocale)) {
    return stored as SupportedLocale
  }
  return detectBrowserLocale()
}

export const i18n = createI18n({
  legacy: false,
  locale: getInitialLocale(),
  fallbackLocale: DEFAULT_LOCALE,
  messages: { hr, en },
})

export function setLocale(locale: SupportedLocale): void {
  i18n.global.locale.value = locale
  localStorage.setItem(STORAGE_KEY, locale)
  document.documentElement.setAttribute('lang', locale)
}
