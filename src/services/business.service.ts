import { BusinessRepository } from '@/repositories/BusinessRepository'
import type { Business, BusinessUpdateInput } from '@/types/domain/business.types'

export const businessService = {
  async getCurrentUserBusiness(profileId: string): Promise<Business | null> {
    const membership = await BusinessRepository.findActiveMembership(profileId)
    if (!membership) return null

    const business = await BusinessRepository.findById(membership.business_id)
    if (!business) return null

    return {
      id: business.id,
      ownerId: business.owner_id,
      name: business.name,
      slug: business.slug,
      category: business.category,
      description: business.description,
      city: business.city,
      addressLine: business.address_line,
      email: business.email,
      phone: business.phone,
      currentUserRole: membership.role,
    }
  },

  async updateBusiness(businessId: string, input: BusinessUpdateInput): Promise<void> {
    await BusinessRepository.update(businessId, {
      name: input.name,
      category: input.category,
      description: input.description,
      city: input.city,
      address_line: input.addressLine,
      email: input.email,
      phone: input.phone,
    })
  },
}
