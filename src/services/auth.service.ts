import type { Session } from '@supabase/supabase-js'

import { supabase } from '@/supabase/client'
import type { BusinessCategory } from '@/types/database.types'

export interface SignUpMetadata {
  businessName?: string
  businessCategory?: BusinessCategory
  businessCity?: string
  firstName?: string
  lastName?: string
}

export const authService = {
  async signUp(
    email: string,
    password: string,
    metadata: SignUpMetadata,
  ): Promise<{ session: Session | null }> {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          business_name: metadata.businessName || undefined,
          business_category: metadata.businessCategory || undefined,
          business_city: metadata.businessCity || undefined,
          first_name: metadata.firstName || undefined,
          last_name: metadata.lastName || undefined,
        },
      },
    })

    if (error) throw error
    return { session: data.session }
  },

  async signIn(email: string, password: string): Promise<Session> {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })

    if (error) throw error
    if (!data.session) throw new Error('Login succeeded but no session was returned.')
    return data.session
  },

  async signInWithGoogle(): Promise<void> {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo: `${window.location.origin}/dashboard` },
    })

    if (error) throw error
  },

  async signOut(): Promise<void> {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  },

  async resetPassword(email: string): Promise<void> {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/reset-password`,
    })

    if (error) throw error
  },

  async updatePassword(newPassword: string): Promise<void> {
    const { error } = await supabase.auth.updateUser({ password: newPassword })
    if (error) throw error
  },
}
