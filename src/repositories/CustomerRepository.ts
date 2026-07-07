import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type CustomerRow = Database['public']['Tables']['customers']['Row']

export const CustomerRepository = {
  async countByBusiness(businessId: string): Promise<number> {
    const { count, error } = await supabase
      .from('customers')
      .select('*', { count: 'exact', head: true })
      .eq('business_id', businessId)

    if (error) throw error
    return count ?? 0
  },

  async findByIds(customerIds: string[]): Promise<CustomerRow[]> {
    if (customerIds.length === 0) return []

    const { data, error } = await supabase.from('customers').select('*').in('id', customerIds)

    if (error) throw error
    return data ?? []
  },

  async listByBusiness(businessId: string): Promise<CustomerRow[]> {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('business_id', businessId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data ?? []
  },

  async findByProfile(profileId: string): Promise<CustomerRow[]> {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('profile_id', profileId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data ?? []
  },

  async findByBusinessAndProfile(
    businessId: string,
    profileId: string,
  ): Promise<CustomerRow | null> {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('business_id', businessId)
      .eq('profile_id', profileId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async findById(customerId: string): Promise<CustomerRow | null> {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('id', customerId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async createSelf(
    businessId: string,
    profileId: string,
    firstName: string,
    lastName: string | null,
  ): Promise<CustomerRow> {
    const { data, error } = await supabase
      .from('customers')
      .insert({
        business_id: businessId,
        profile_id: profileId,
        first_name: firstName,
        last_name: lastName,
      })
      .select()
      .single()

    if (error) throw error
    return data
  },
}
