import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type PromoCodeRow = Database['public']['Tables']['promo_codes']['Row']
type PromoCodeInsert = Database['public']['Tables']['promo_codes']['Insert']
type PromoCodeUpdate = Database['public']['Tables']['promo_codes']['Update']

export const PromoCodeRepository = {
  async listForBusiness(businessId: string): Promise<PromoCodeRow[]> {
    const { data, error } = await supabase
      .from('promo_codes')
      .select('*')
      .eq('business_id', businessId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data ?? []
  },

  async create(input: PromoCodeInsert): Promise<PromoCodeRow> {
    const { data, error } = await supabase.from('promo_codes').insert(input).select().single()

    if (error) throw error
    return data
  },

  async update(id: string, input: PromoCodeUpdate): Promise<PromoCodeRow> {
    const { data, error } = await supabase
      .from('promo_codes')
      .update(input)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
