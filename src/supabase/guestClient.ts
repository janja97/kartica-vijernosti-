import { createClient } from '@supabase/supabase-js'

import type { Database } from '@/types/database.types'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase configuration. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in your .env file.',
  )
}

// A second, isolated Supabase client used only by the public guest-entry page
// (CustomerEntryPage.vue). It writes its session under a distinct storageKey
// so that verifying an OTP code on a shared device (e.g. a front-desk tablet)
// never overwrites a staff dashboard session sharing the same browser.
export const guestSupabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: false,
    storageKey: 'loyalflow-guest-auth',
  },
})
