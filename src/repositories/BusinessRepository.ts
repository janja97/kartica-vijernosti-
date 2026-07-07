import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type BusinessRow = Database['public']['Tables']['businesses']['Row']
type BusinessMemberRow = Database['public']['Tables']['business_members']['Row']
type BusinessCategory = Database['public']['Tables']['businesses']['Row']['category']
type BusinessUpdate = Database['public']['Tables']['businesses']['Update']

export interface BusinessDirectoryFilters {
  category?: BusinessCategory
  city?: string
}

export const BusinessRepository = {
  async findActiveMembership(profileId: string): Promise<BusinessMemberRow | null> {
    const { data, error } = await supabase
      .from('business_members')
      .select('*')
      .eq('profile_id', profileId)
      .eq('is_active', true)
      .limit(1)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async findById(businessId: string): Promise<BusinessRow | null> {
    const { data, error } = await supabase
      .from('businesses')
      .select('*')
      .eq('id', businessId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async listDirectory(filters: BusinessDirectoryFilters = {}): Promise<BusinessRow[]> {
    let query = supabase.from('businesses').select('*').eq('is_active', true)

    if (filters.category) {
      query = query.eq('category', filters.category)
    }
    if (filters.city) {
      query = query.ilike('city', `%${filters.city}%`)
    }

    const { data, error } = await query.order('name', { ascending: true })

    if (error) throw error
    return data ?? []
  },

  async update(businessId: string, input: BusinessUpdate): Promise<BusinessRow> {
    const { data, error } = await supabase
      .from('businesses')
      .update(input)
      .eq('id', businessId)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
