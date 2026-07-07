import type { Session, User } from '@supabase/supabase-js'
import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

import { supabase } from '@/supabase/client'

export const useAuthStore = defineStore('auth', () => {
  const session = ref<Session | null>(null)
  const isReady = ref(false)

  const user = computed<User | null>(() => session.value?.user ?? null)
  const isAuthenticated = computed(() => session.value !== null)

  let initialized = false

  async function initialize(): Promise<void> {
    if (initialized) return
    initialized = true

    const { data } = await supabase.auth.getSession()
    session.value = data.session
    isReady.value = true

    supabase.auth.onAuthStateChange((_event, newSession) => {
      session.value = newSession
    })
  }

  return { session, user, isReady, isAuthenticated, initialize }
})
