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
    minimumSpendAmount: row.minimum_spend_amount,
    minimumSpendBonus: row.minimum_spend_bonus,
    expiryDays: row.expiry_days,
    imageUrl: row.image_url,
    isActive: row.is_active,
  }
}

export interface LoyaltyProgramInput {
  name: string
  description: string | null
  pointsPerVisit: number
  minimumSpendAmount: number | null
  minimumSpendBonus: number | null
  expiryDays: number | null
  imageUrl?: string | null
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
      minimum_spend_amount: input.minimumSpendAmount,
      minimum_spend_bonus: input.minimumSpendBonus,
      expiry_days: input.expiryDays,
    })
    return toDomain(row)
  },

  async update(id: string, input: Partial<LoyaltyProgramInput>): Promise<LoyaltyProgram> {
    const row = await LoyaltyProgramRepository.update(id, {
      name: input.name,
      description: input.description,
      points_per_visit: input.pointsPerVisit,
      minimum_spend_amount: input.minimumSpendAmount,
      minimum_spend_bonus: input.minimumSpendBonus,
      expiry_days: input.expiryDays,
      image_url: input.imageUrl,
      is_active: input.isActive,
    })
    return toDomain(row)
  },

  async updateImage(id: string, imageUrl: string | null): Promise<LoyaltyProgram> {
    const row = await LoyaltyProgramRepository.update(id, { image_url: imageUrl })
    return toDomain(row)
  },
}
