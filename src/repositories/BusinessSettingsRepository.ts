import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type BusinessSettingsRow = Database['public']['Tables']['business_settings']['Row']
type BusinessSettingsUpdate = Database['public']['Tables']['business_settings']['Update']

export const BusinessSettingsRepository = {
  async findByBusiness(businessId: string): Promise<BusinessSettingsRow | null> {
    const { data, error } = await supabase
      .from('business_settings')
      .select('*')
      .eq('business_id', businessId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async update(businessId: string, input: BusinessSettingsUpdate): Promise<BusinessSettingsRow> {
    const { data, error } = await supabase
      .from('business_settings')
      .update(input)
      .eq('business_id', businessId)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
