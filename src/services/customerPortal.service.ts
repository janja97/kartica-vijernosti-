import {
  BusinessRepository,
  type BusinessDirectoryFilters,
} from '@/repositories/BusinessRepository'
import { CustomerRepository } from '@/repositories/CustomerRepository'
import { LoyaltyProgramRepository } from '@/repositories/LoyaltyProgramRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import { ProfileRepository } from '@/repositories/ProfileRepository'
import { QrCodeRepository } from '@/repositories/QrCodeRepository'
import { RewardRedemptionRepository } from '@/repositories/RewardRedemptionRepository'
import { RewardRepository } from '@/repositories/RewardRepository'
import { createLoyaltyCardForProgram } from '@/services/shared/loyaltyCardCreation'
import type {
  BusinessDetail,
  BusinessDirectoryItem,
  CardDetail,
  MyCard,
} from '@/types/domain/card.types'

function isDue(expiresAt: string | null, status: string): boolean {
  return status === 'active' && expiresAt !== null && new Date(expiresAt).getTime() < Date.now()
}

export const customerPortalService = {
  async listBusinessDirectory(
    filters: BusinessDirectoryFilters = {},
  ): Promise<BusinessDirectoryItem[]> {
    const businesses = await BusinessRepository.listDirectory(filters)
    return businesses.map((business) => ({
      id: business.id,
      name: business.name,
      slug: business.slug,
      category: business.category,
      city: business.city,
      description: business.description,
    }))
  },

  async getBusinessDetail(businessId: string): Promise<BusinessDetail | null> {
    const business = await BusinessRepository.findById(businessId)
    if (!business) return null

    const programs = await LoyaltyProgramRepository.listActiveForBusiness(businessId)

    return {
      id: business.id,
      name: business.name,
      slug: business.slug,
      category: business.category,
      city: business.city,
      description: business.description,
      programs: programs.map((program) => ({
        id: program.id,
        businessId: program.business_id,
        name: program.name,
        description: program.description,
        type: program.type,
        color: program.color,
        pointsPerVisit: program.points_per_visit,
        imageUrl: program.image_url,
      })),
    }
  },

  async joinProgram(profileId: string, businessId: string, programId: string): Promise<string> {
    let customer = await CustomerRepository.findByBusinessAndProfile(businessId, profileId)

    if (!customer) {
      const profile = await ProfileRepository.findById(profileId)
      const firstName = profile?.first_name || profile?.email.split('@')[0] || 'Korisnik'
      customer = await CustomerRepository.createSelf(
        businessId,
        profileId,
        firstName,
        profile?.last_name ?? null,
      )
    }

    let card = await LoyaltyRepository.findActiveCardByCustomerAndProgram(customer.id, programId)
    if (!card) {
      card = await createLoyaltyCardForProgram(businessId, customer.id, programId)
    }

    return card.id
  },

  async getMyCards(profileId: string): Promise<MyCard[]> {
    const customers = await CustomerRepository.findByProfile(profileId)
    if (customers.length === 0) return []

    const customerIds = customers.map((customer) => customer.id)
    let cards = await LoyaltyRepository.findCardsForCustomers(customerIds)
    cards = cards.filter((card) => card.status !== 'completed')
    if (cards.length === 0) return []

    const dueForExpiry = cards.filter((card) => isDue(card.expires_at, card.status))
    if (dueForExpiry.length > 0) {
      await Promise.all(dueForExpiry.map((card) => LoyaltyRepository.expireCardIfDue(card.id)))
      cards = (await LoyaltyRepository.findCardsForCustomers(customerIds)).filter(
        (card) => card.status !== 'completed',
      )
    }

    const businessIds = [...new Set(cards.map((card) => card.business_id))]
    const programIds = [...new Set(cards.map((card) => card.loyalty_program_id))]

    const [businesses, programs, rewardsByBusiness, qrCode] = await Promise.all([
      Promise.all(businessIds.map((id) => BusinessRepository.findById(id))),
      Promise.all(programIds.map((id) => LoyaltyProgramRepository.findById(id))),
      Promise.all(businessIds.map((id) => RewardRepository.listActiveForBusiness(id))),
      QrCodeRepository.findByProfile(profileId),
    ])
    const businessById = new Map(businesses.filter((b) => b !== null).map((b) => [b.id, b]))
    const programById = new Map(programs.filter((p) => p !== null).map((p) => [p.id, p]))
    const cheapestRewardByBusiness = new Map(
      businessIds.map((id, index) => [
        id,
        rewardsByBusiness[index]?.find((reward) => reward.points_cost !== null)?.points_cost ??
          null,
      ]),
    )

    return cards.map((card) => ({
      id: card.id,
      businessId: card.business_id,
      businessName: businessById.get(card.business_id)?.name ?? 'Nepoznata tvrtka',
      businessLogoUrl: businessById.get(card.business_id)?.logo_url ?? null,
      programId: card.loyalty_program_id,
      programName: programById.get(card.loyalty_program_id)?.name ?? '',
      programImageUrl: programById.get(card.loyalty_program_id)?.image_url ?? null,
      currentPoints: card.current_points,
      cardNumber: card.card_number,
      nextRewardThreshold: cheapestRewardByBusiness.get(card.business_id) ?? null,
      qrCode: qrCode?.code ?? '',
      isExpired: card.status === 'expired',
      expiresAt: card.expires_at,
    }))
  },

  async getCardDetail(cardId: string): Promise<CardDetail | null> {
    let card = await LoyaltyRepository.findCardById(cardId)
    if (!card || card.status === 'completed') return null

    if (isDue(card.expires_at, card.status)) {
      await LoyaltyRepository.expireCardIfDue(card.id)
      card = await LoyaltyRepository.findCardById(cardId)
      if (!card) return null
    }

    const customer = await CustomerRepository.findById(card.customer_id)

    const [business, program, qrCode, rewards] = await Promise.all([
      BusinessRepository.findById(card.business_id),
      LoyaltyProgramRepository.findById(card.loyalty_program_id),
      customer?.profile_id ? QrCodeRepository.findByProfile(customer.profile_id) : null,
      RewardRepository.listActiveForBusiness(card.business_id),
    ])

    return {
      id: card.id,
      businessId: card.business_id,
      businessName: business?.name ?? '',
      businessLogoUrl: business?.logo_url ?? null,
      programId: card.loyalty_program_id,
      programName: program?.name ?? '',
      programImageUrl: program?.image_url ?? null,
      currentPoints: card.current_points,
      cardNumber: card.card_number,
      nextRewardThreshold:
        rewards.find((reward) => reward.points_cost !== null)?.points_cost ?? null,
      qrCode: qrCode?.code ?? '',
      isExpired: card.status === 'expired',
      expiresAt: card.expires_at,
      rewards: rewards.map((reward) => ({
        id: reward.id,
        businessId: reward.business_id,
        loyaltyProgramId: reward.loyalty_program_id,
        name: reward.name,
        description: reward.description,
        type: reward.type,
        pointsCost: reward.points_cost,
        discountPercent: reward.discount_percent,
        isActive: reward.is_active,
        isGoal: reward.is_goal,
        affordable: reward.points_cost !== null && card.current_points >= reward.points_cost,
      })),
    }
  },

  async requestRedemption(cardId: string, rewardId: string): Promise<void> {
    const card = await LoyaltyRepository.findCardById(cardId)
    if (!card) throw new Error('Kartica nije pronađena.')
    if (card.status === 'expired' || isDue(card.expires_at, card.status)) {
      throw new Error('Kartica je istekla i više se ne može koristiti.')
    }

    const [reward] = await RewardRepository.findByIds([rewardId])
    if (!reward) throw new Error('Nagrada nije pronađena.')
    if (reward.points_cost === null || card.current_points < reward.points_cost) {
      throw new Error('Nemaš dovoljno bodova za ovu nagradu.')
    }

    await RewardRedemptionRepository.create({
      business_id: card.business_id,
      customer_id: card.customer_id,
      reward_id: rewardId,
      loyalty_card_id: card.id,
      points_spent: reward.points_cost,
      status: 'pending',
    })
  },
}
