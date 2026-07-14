import { supabase } from '@/supabase/client'
import type { Database } from '@/types/database.types'

type QrCodeRow = Database['public']['Tables']['qr_codes']['Row']
type ScanResolveProfileRow =
  Database['public']['Functions']['scan_resolve_profile']['Returns'][number]

export const QrCodeRepository = {
  async findByProfile(profileId: string): Promise<QrCodeRow | null> {
    const { data, error } = await supabase
      .from('qr_codes')
      .select('*')
      .eq('profile_id', profileId)
      .maybeSingle()

    if (error) throw error
    return data
  },

  async resolveForScan(code: string, businessId: string): Promise<ScanResolveProfileRow | null> {
    const { data, error } = await supabase.rpc('scan_resolve_profile', {
      target_code: code,
      target_business_id: businessId,
    })

    if (error) throw error
    return data?.[0] ?? null
  },
}
