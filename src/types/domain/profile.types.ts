export interface Profile {
  id: string
  email: string
  firstName: string | null
  lastName: string | null
  phone: string | null
  dateOfBirth: string | null
  avatarUrl: string | null
}

export interface ProfileUpdateInput {
  firstName: string | null
  lastName: string | null
  phone: string | null
  dateOfBirth: string | null
}
