import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type ActivityLogRow = Database['public']['Tables']['activity_logs']['Row']

export const DashboardRepository = {
  async countRedemptions(businessId: string, status?: 'fulfilled'): Promise<number> {
    let query = supabase
      .from('reward_redemptions')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId)

    if (status) {
      query = query.eq('status', status)
    }

    const { count, error } = await query

    if (error) throw error
    return count ?? 0
  },

  async recentActivity(businessId: string, limit: number): Promise<ActivityLogRow[]> {
    const { data, error } = await supabase
      .from('activity_logs')
      .select('*')
      .eq('business_id', businessId)
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data ?? []
  },
}
