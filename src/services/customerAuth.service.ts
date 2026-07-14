import { CustomerRepository } from '@/repositories/CustomerRepository'
import { supabase } from '@/supabase/client'
import { guestSupabase } from '@/supabase/guestClient'

export const customerAuthService = {
  async requestCode(email: string): Promise<void> {
    const { error } = await guestSupabase.auth.signInWithOtp({
      email,
      options: { shouldCreateUser: true },
    })
    if (error) throw error
  },

  async verifyCode(email: string, token: string): Promise<void> {
    const { data, error } = await guestSupabase.auth.verifyOtp({ email, token, type: 'email' })
    if (error) throw error
    if (!data.session) throw new Error('Prijava nije uspjela. Pokušaj ponovno.')

    const { error: setSessionError } = await supabase.auth.setSession({
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
    })
    if (setSessionError) throw setSessionError

    await CustomerRepository.claimGuestCustomers()
  },
}
