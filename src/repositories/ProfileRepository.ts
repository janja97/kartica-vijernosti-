import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type ProfileRow = Database['public']['Tables']['profiles']['Row']
type ProfileUpdate = Database['public']['Tables']['profiles']['Update']

export const ProfileRepository = {
  async findById(profileId: string): Promise<ProfileRow | null> {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', profileId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async update(profileId: string, input: ProfileUpdate): Promise<ProfileRow> {
    const { data, error } = await supabase
      .from('profiles')
      .update(input)
      .eq('id', profileId)
      .select()
      .single()

    if (error) throw error
    return data
  },
}
