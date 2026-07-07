import { CustomerRepository } from '@/repositories/CustomerRepository'
import { LoyaltyRepository } from '@/repositories/LoyaltyRepository'
import type { BusinessCustomer } from '@/types/domain/customer.types'

export const customerService = {
  async listForBusiness(businessId: string): Promise<BusinessCustomer[]> {
    const customers = await CustomerRepository.listByBusiness(businessId)
    if (customers.length === 0) return []

    const cards = await LoyaltyRepository.findCardsForCustomers(
      customers.map((customer) => customer.id),
    )
    const pointsByCustomer = new Map<string, number>()
    for (const card of cards) {
      pointsByCustomer.set(
        card.customer_id,
        (pointsByCustomer.get(card.customer_id) ?? 0) + card.current_points,
      )
    }

    return customers.map((customer) => ({
      id: customer.id,
      name: `${customer.first_name} ${customer.last_name ?? ''}`.trim(),
      email: customer.email,
      points: pointsByCustomer.get(customer.id) ?? 0,
      joinedAt: customer.joined_at,
    }))
  },
}
