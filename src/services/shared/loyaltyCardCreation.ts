import { LoyaltyProgramRepository } from '@/repositories/LoyaltyProgramRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import type { Database } from '@/types/database.types'

type LoyaltyCardRow = Database['public']['Tables']['loyalty_cards']['Row']

function generateCardNumber(): string {
  return `LF-${Math.random().toString(36).slice(2, 10).toUpperCase()}`
}

export async function createLoyaltyCardForProgram(
  businessId: string,
  customerId: string,
  programId: string,
): Promise<LoyaltyCardRow> {
  const program = await LoyaltyProgramRepository.findById(programId)
  const expiresAt = program?.expiry_days
    ? new Date(Date.now() + program.expiry_days * 24 * 60 * 60 * 1000).toISOString()
    : null

  return LoyaltyRepository.createCard(
    businessId,
    customerId,
    programId,
    generateCardNumber(),
    expiresAt,
  )
}
