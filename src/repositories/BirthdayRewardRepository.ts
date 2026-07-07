import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type BirthdayRewardRow = Database['public']['Tables']['birthday_rewards']['Row']
type BirthdayRewardInsert = Database['public']['Tables']['birthday_rewards']['Insert']

export const BirthdayRewardRepository = {
  async findByBusiness(businessId: string): Promise<BirthdayRewardRow | null> {
    const { data, error } = await supabase
      .from('birthday_rewards')
      .select('*')
      .eq('business_id', businessId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async upsert(input: BirthdayRewardInsert): Promise<BirthdayRewardRow> {
    const { data, error } = await supabase
      .from('birthday_rewards')
      .upsert(input, { onConflict: 'business_id' })
      .select()
      .single()

    if (error) throw error
    return data
  },
}
