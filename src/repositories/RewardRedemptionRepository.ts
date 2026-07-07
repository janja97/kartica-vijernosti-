import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type RewardRedemptionRow = Database['public']['Tables']['reward_redemptions']['Row']
type RewardRedemptionInsert = Database['public']['Tables']['reward_redemptions']['Insert']

export const RewardRedemptionRepository = {
  async create(input: RewardRedemptionInsert): Promise<RewardRedemptionRow> {
    const { data, error } = await supabase
      .from('reward_redemptions')
      .insert(input)
      .select()
      .single()

    if (error) throw error
    return data
  },

  async listPendingForBusiness(businessId: string): Promise<RewardRedemptionRow[]> {
    const { data, error } = await supabase
      .from('reward_redemptions')
      .select('*')
      .eq('business_id', businessId)
      .eq('status', 'pending')
      .order('created_at', { ascending: true })

    if (error) throw error
    return data ?? []
  },

  async listPendingForCard(cardId: string): Promise<RewardRedemptionRow[]> {
    const { data, error } = await supabase
      .from('reward_redemptions')
      .select('*')
      .eq('loyalty_card_id', cardId)
      .eq('status', 'pending')

    if (error) throw error
    return data ?? []
  },

  async fulfill(id: string): Promise<RewardRedemptionRow> {
    const { data, error } = await supabase
      .from('reward_redemptions')
      .update({ status: 'fulfilled', redeemed_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
