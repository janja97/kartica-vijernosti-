import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type LoyaltyCardRow = Database['public']['Tables']['loyalty_cards']['Row']
type CustomerVisitRow = Database['public']['Tables']['customer_visits']['Row']
type PointTransactionInsert = Database['public']['Tables']['point_transactions']['Insert']
type CustomerVisitInsert = Database['public']['Tables']['customer_visits']['Insert']

export const LoyaltyRepository = {
  async findCardById(cardId: string): Promise<LoyaltyCardRow | null> {
    const { data, error } = await supabase
      .from('loyalty_cards')
      .select('*')
      .eq('id', cardId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async findCardByCustomerAndProgram(
    customerId: string,
    programId: string,
  ): Promise<LoyaltyCardRow | null> {
    const { data, error } = await supabase
      .from('loyalty_cards')
      .select('*')
      .eq('customer_id', customerId)
      .eq('loyalty_program_id', programId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async findCardsForCustomers(customerIds: string[]): Promise<LoyaltyCardRow[]> {
    if (customerIds.length === 0) return []

    const { data, error } = await supabase
      .from('loyalty_cards')
      .select('*')
      .in('customer_id', customerIds)

    if (error) throw error
    return data ?? []
  },

  async createCard(
    businessId: string,
    customerId: string,
    programId: string,
    cardNumber: string,
  ): Promise<LoyaltyCardRow> {
    const { data, error } = await supabase
      .from('loyalty_cards')
      .insert({
        business_id: businessId,
        customer_id: customerId,
        loyalty_program_id: programId,
        card_number: cardNumber,
      })
      .select()
      .single()

    if (error) throw error
    return data
  },

  async insertPointTransaction(input: PointTransactionInsert): Promise<void> {
    const { error } = await supabase.from('point_transactions').insert(input)
    if (error) throw error
  },

  async insertVisit(input: CustomerVisitInsert): Promise<void> {
    const { error } = await supabase.from('customer_visits').insert(input)
    if (error) throw error
  },

  async listCardsForBusiness(businessId: string): Promise<LoyaltyCardRow[]> {
    const { data, error } = await supabase
      .from('loyalty_cards')
      .select('*')
      .eq('business_id', businessId)

    if (error) throw error
    return data ?? []
  },

  async countActiveCards(businessId: string): Promise<number> {
    const { count, error } = await supabase
      .from('loyalty_cards')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId)
      .eq('status', 'active')

    if (error) throw error
    return count ?? 0
  },

  async topCardsByPoints(businessId: string, limit: number): Promise<LoyaltyCardRow[]> {
    const { data, error } = await supabase
      .from('loyalty_cards')
      .select('*')
      .eq('business_id', businessId)
      .order('current_points', { ascending: false })
      .limit(limit)

    if (error) throw error
    return data ?? []
  },

  async visitsSince(businessId: string, sinceIso: string): Promise<CustomerVisitRow[]> {
    const { data, error } = await supabase
      .from('customer_visits')
      .select('*')
      .eq('business_id', businessId)
      .gte('visited_at', sinceIso)
      .order('visited_at', { ascending: true })

    if (error) throw error
    return data ?? []
  },

  async countVisitsSince(businessId: string, sinceIso: string): Promise<number> {
    const { count, error } = await supabase
      .from('customer_visits')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId)
      .gte('visited_at', sinceIso)

    if (error) throw error
    return count ?? 0
  },

  async countVisitsByCustomers(
    businessId: string,
    customerIds: string[],
  ): Promise<Record<string, number>> {
    if (customerIds.length === 0) return {}

    const { data, error } = await supabase
      .from('customer_visits')
      .select('*')
      .eq('business_id', businessId)
      .in('customer_id', customerIds)

    if (error) throw error

    const rows = (data ?? []) as CustomerVisitRow[]
    const counts: Record<string, number> = {}
    for (const row of rows) {
      counts[row.customer_id] = (counts[row.customer_id] ?? 0) + 1
    }
    return counts
  },
}
