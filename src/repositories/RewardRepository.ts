import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type RewardCatalogRow = Database['public']['Tables']['reward_catalog']['Row']
type RewardCatalogInsert = Database['public']['Tables']['reward_catalog']['Insert']
type RewardCatalogUpdate = Database['public']['Tables']['reward_catalog']['Update']

export const RewardRepository = {
  async listActiveForBusiness(businessId: string): Promise<RewardCatalogRow[]> {
    const { data, error } = await supabase
      .from('reward_catalog')
      .select('*')
      .eq('business_id', businessId)
      .eq('is_active', true)
      .order('points_cost', { ascending: true })

    if (error) throw error
    return data ?? []
  },

  async listForBusiness(businessId: string): Promise<RewardCatalogRow[]> {
    const { data, error } = await supabase
      .from('reward_catalog')
      .select('*')
      .eq('business_id', businessId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data ?? []
  },

  async findByIds(ids: string[]): Promise<RewardCatalogRow[]> {
    if (ids.length === 0) return []

    const { data, error } = await supabase.from('reward_catalog').select('*').in('id', ids)

    if (error) throw error
    return data ?? []
  },

  async create(input: RewardCatalogInsert): Promise<RewardCatalogRow> {
    const { data, error } = await supabase.from('reward_catalog').insert(input).select().single()

    if (error) throw error
    return data
  },

  async update(id: string, input: RewardCatalogUpdate): Promise<RewardCatalogRow> {
    const { data, error } = await supabase
      .from('reward_catalog')
      .update(input)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
