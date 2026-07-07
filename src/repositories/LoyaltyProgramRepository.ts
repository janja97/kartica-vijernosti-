import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type LoyaltyProgramRow = Database['public']['Tables']['loyalty_programs']['Row']
type LoyaltyProgramInsert = Database['public']['Tables']['loyalty_programs']['Insert']
type LoyaltyProgramUpdate = Database['public']['Tables']['loyalty_programs']['Update']

export const LoyaltyProgramRepository = {
  async listActiveForBusiness(businessId: string): Promise<LoyaltyProgramRow[]> {
    const { data, error } = await supabase
      .from('loyalty_programs')
      .select('*')
      .eq('business_id', businessId)
      .eq('is_active', true)
      .order('created_at', { ascending: true })

    if (error) throw error
    return data ?? []
  },

  async listForBusiness(businessId: string): Promise<LoyaltyProgramRow[]> {
    const { data, error } = await supabase
      .from('loyalty_programs')
      .select('*')
      .eq('business_id', businessId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data ?? []
  },

  async findById(id: string): Promise<LoyaltyProgramRow | null> {
    const { data, error } = await supabase
      .from('loyalty_programs')
      .select('*')
      .eq('id', id)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async create(input: LoyaltyProgramInsert): Promise<LoyaltyProgramRow> {
    const { data, error } = await supabase.from('loyalty_programs').insert(input).select().single()

    if (error) throw error
    return data
  },

  async update(id: string, input: LoyaltyProgramUpdate): Promise<LoyaltyProgramRow> {
    const { data, error } = await supabase
      .from('loyalty_programs')
      .update(input)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
