import { LoyaltyProgramRepository } from '@/repositories/LoyaltyProgramRepository'
import type { Database } from '@/types/database.types'
import type { LoyaltyProgram } from '@/types/domain/card.types'

type LoyaltyProgramRow = Database['public']['Tables']['loyalty_programs']['Row']

function toDomain(row: LoyaltyProgramRow): LoyaltyProgram {
  return {
    id: row.id,
    businessId: row.business_id,
    name: row.name,
    description: row.description,
    type: row.type,
    color: row.color,
    pointsPerVisit: row.points_per_visit,
    isActive: row.is_active,
  }
}

export interface LoyaltyProgramInput {
  name: string
  description: string | null
  pointsPerVisit: number
  isActive?: boolean
}

export const loyaltyProgramService = {
  async list(businessId: string): Promise<LoyaltyProgram[]> {
    const rows = await LoyaltyProgramRepository.listForBusiness(businessId)
    return rows.map(toDomain)
  },

  async create(businessId: string, input: LoyaltyProgramInput): Promise<LoyaltyProgram> {
    const row = await LoyaltyProgramRepository.create({
      business_id: businessId,
      name: input.name,
      description: input.description,
      type: 'points',
      points_per_visit: input.pointsPerVisit,
    })
    return toDomain(row)
  },

  async update(id: string, input: Partial<LoyaltyProgramInput>): Promise<LoyaltyProgram> {
    const row = await LoyaltyProgramRepository.update(id, {
      name: input.name,
      description: input.description,
      points_per_visit: input.pointsPerVisit,
      is_active: input.isActive,
    })
    return toDomain(row)
  },
}
