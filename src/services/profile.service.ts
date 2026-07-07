import { ProfileRepository } from '@/repositories/ProfileRepository'
import type { Profile, ProfileUpdateInput } from '@/types/domain/profile.types'

export const profileService = {
  async getProfile(profileId: string): Promise<Profile | null> {
    const row = await ProfileRepository.findById(profileId)
    if (!row) return null

    return {
      id: row.id,
      email: row.email,
      firstName: row.first_name,
      lastName: row.last_name,
      phone: row.phone,
      dateOfBirth: row.date_of_birth,
      avatarUrl: row.avatar_url,
    }
  },

  async updateProfile(profileId: string, input: ProfileUpdateInput): Promise<void> {
    await ProfileRepository.update(profileId, {
      first_name: input.firstName,
      last_name: input.lastName,
      phone: input.phone,
      date_of_birth: input.dateOfBirth,
    })
  },
}
