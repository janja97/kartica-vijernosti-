import type { BusinessCategory } from '@/types/database.types'

export type BusinessMemberRole = 'owner' | 'admin' | 'employee'

export interface Business {
  id: string
  ownerId: string
  name: string
  slug: string
  category: BusinessCategory
  description: string | null
  city: string | null
  addressLine: string | null
  email: string | null
  phone: string | null
  currentUserRole: BusinessMemberRole
}

export interface BusinessUpdateInput {
  name: string
  category: BusinessCategory
  description: string | null
  city: string | null
  addressLine: string | null
  email: string | null
  phone: string | null
}
