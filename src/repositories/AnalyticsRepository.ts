import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type PointTransactionRow = Database['public']['Tables']['point_transactions']['Row']

export const AnalyticsRepository = {
  async listPointTransactions(businessId: string): Promise<PointTransactionRow[]> {
    const { data, error } = await supabase
      .from('point_transactions')
      .select('*')
      .eq('business_id', businessId)

    if (error) throw error
    return data ?? []
  },

  async countCustomersSince(businessId: string, sinceIso: string): Promise<number> {
    const { count, error } = await supabase
      .from('customers')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId)
      .gte('created_at', sinceIso)

    if (error) throw error
    return count ?? 0
  },
}
