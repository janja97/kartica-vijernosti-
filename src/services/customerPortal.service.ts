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
import type {
  BusinessDetail,
  BusinessDirectoryItem,
  CardDetail,
  MyCard,
} from '@/types/domain/card.types'

function generateCardNumber(): string {
  return `LF-${Math.random().toString(36).slice(2, 10).toUpperCase()}`
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

    let card = await LoyaltyRepository.findCardByCustomerAndProgram(customer.id, programId)
    if (!card) {
      card = await LoyaltyRepository.createCard(
        businessId,
        customer.id,
        programId,
        generateCardNumber(),
      )
    }

    return card.id
  },

  async getMyCards(profileId: string): Promise<MyCard[]> {
    const customers = await CustomerRepository.findByProfile(profileId)
    if (customers.length === 0) return []

    const customerIds = customers.map((customer) => customer.id)
    const cards = await LoyaltyRepository.findCardsForCustomers(customerIds)
    if (cards.length === 0) return []

    const businessIds = [...new Set(cards.map((card) => card.business_id))]
    const programIds = [...new Set(cards.map((card) => card.loyalty_program_id))]
    const cardCustomerIds = [...new Set(cards.map((card) => card.customer_id))]

    const [businesses, programs, rewardsByBusiness, qrCodes] = await Promise.all([
      Promise.all(businessIds.map((id) => BusinessRepository.findById(id))),
      Promise.all(programIds.map((id) => LoyaltyProgramRepository.findById(id))),
      Promise.all(businessIds.map((id) => RewardRepository.listActiveForBusiness(id))),
      Promise.all(cardCustomerIds.map((id) => QrCodeRepository.findByCustomer(id))),
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
    const qrCodeByCustomer = new Map(
      cardCustomerIds.map((id, index) => [id, qrCodes[index]?.code ?? '']),
    )

    return cards.map((card) => ({
      id: card.id,
      businessId: card.business_id,
      businessName: businessById.get(card.business_id)?.name ?? 'Nepoznata tvrtka',
      programId: card.loyalty_program_id,
      programName: programById.get(card.loyalty_program_id)?.name ?? '',
      currentPoints: card.current_points,
      cardNumber: card.card_number,
      nextRewardThreshold: cheapestRewardByBusiness.get(card.business_id) ?? null,
      qrCode: qrCodeByCustomer.get(card.customer_id) ?? '',
    }))
  },

  async getCardDetail(cardId: string): Promise<CardDetail | null> {
    const card = await LoyaltyRepository.findCardById(cardId)
    if (!card) return null

    const [business, program, qrCode, rewards] = await Promise.all([
      BusinessRepository.findById(card.business_id),
      LoyaltyProgramRepository.findById(card.loyalty_program_id),
      QrCodeRepository.findByCustomer(card.customer_id),
      RewardRepository.listActiveForBusiness(card.business_id),
    ])

    return {
      id: card.id,
      businessId: card.business_id,
      businessName: business?.name ?? '',
      programId: card.loyalty_program_id,
      programName: program?.name ?? '',
      currentPoints: card.current_points,
      cardNumber: card.card_number,
      nextRewardThreshold:
        rewards.find((reward) => reward.points_cost !== null)?.points_cost ?? null,
      qrCode: qrCode?.code ?? '',
      rewards: rewards.map((reward) => ({
        id: reward.id,
        businessId: reward.business_id,
        loyaltyProgramId: reward.loyalty_program_id,
        name: reward.name,
        description: reward.description,
        type: reward.type,
        pointsCost: reward.points_cost,
        isActive: reward.is_active,
        affordable: reward.points_cost !== null && card.current_points >= reward.points_cost,
      })),
    }
  },

  async requestRedemption(cardId: string, rewardId: string): Promise<void> {
    const card = await LoyaltyRepository.findCardById(cardId)
    if (!card) throw new Error('Kartica nije pronađena.')

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
