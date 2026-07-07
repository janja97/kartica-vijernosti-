import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type QrCodeRow = Database['public']['Tables']['qr_codes']['Row']

export const QrCodeRepository = {
  async findByCode(code: string, businessId: string): Promise<QrCodeRow | null> {
    const { data, error } = await supabase
      .from('qr_codes')
      .select('*')
      .eq('code', code)
      .eq('business_id', businessId)
      .eq('is_active', true)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async findByCustomer(customerId: string): Promise<QrCodeRow | null> {
    const { data, error } = await supabase
      .from('qr_codes')
      .select('*')
      .eq('customer_id', customerId)
      .maybeSingle()

    if (error) throw error
    return data
  },
}
