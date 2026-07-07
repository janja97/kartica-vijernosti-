// Hand-written to match supabase/schema.sql for the tables the app currently
// queries. Once the Supabase CLI is linked to the project, replace this file
// with the output of `supabase gen types typescript --project-id <ref>`.

export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type UserRole = 'user' | 'super_admin'
export type BusinessMemberRole = 'owner' | 'admin' | 'employee'
export type BusinessCategory =
  | 'restaurant'
  | 'cafe'
  | 'hair_salon'
  | 'beauty_salon'
  | 'fitness'
  | 'gym'
  | 'car_wash'
  | 'auto_service'
  | 'retail'
  | 'bakery'
  | 'patisserie'
  | 'hotel'
  | 'apartment'
  | 'dental'
  | 'veterinary'
  | 'other'
export type LoyaltyProgramType = 'points' | 'stamps' | 'vip' | 'tiers' | 'cashback' | 'custom'
export type LoyaltyCardStatus = 'active' | 'expired' | 'suspended'
export type PointTransactionType =
  'earn' | 'redeem' | 'adjustment' | 'expire' | 'referral_bonus' | 'birthday_bonus'
export type RedemptionStatus = 'pending' | 'approved' | 'rejected' | 'fulfilled'
export type CustomerRewardSource = 'redemption' | 'birthday' | 'referral' | 'campaign' | 'manual'
export type CustomerRewardStatus = 'active' | 'used' | 'expired'
export type RewardType = 'free_item' | 'discount' | 'gift' | 'cashback' | 'coupon' | 'vip_perk'
export type BirthdayRewardType =
  'discount' | 'free_item' | 'free_service' | 'gift' | 'points_bonus' | 'none'

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          email: string
          first_name: string | null
          last_name: string | null
          phone: string | null
          avatar_url: string | null
          date_of_birth: string | null
          role: UserRole
          locale: string
          timezone: string
          is_active: boolean
          last_seen_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          email: string
          first_name?: string | null
          last_name?: string | null
          phone?: string | null
          avatar_url?: string | null
          date_of_birth?: string | null
          role?: UserRole
          locale?: string
          timezone?: string
          is_active?: boolean
          last_seen_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>
        Relationships: []
      }
      businesses: {
        Row: {
          id: string
          owner_id: string
          name: string
          slug: string
          category: BusinessCategory
          description: string | null
          logo_url: string | null
          cover_image_url: string | null
          email: string | null
          phone: string | null
          website: string | null
          address_line: string | null
          city: string | null
          country: string
          postal_code: string | null
          currency: string
          timezone: string
          is_active: boolean
          onboarding_completed: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          owner_id: string
          name: string
          slug: string
          category?: BusinessCategory
          description?: string | null
          logo_url?: string | null
          cover_image_url?: string | null
          email?: string | null
          phone?: string | null
          website?: string | null
          address_line?: string | null
          city?: string | null
          country?: string
          postal_code?: string | null
          currency?: string
          timezone?: string
          is_active?: boolean
          onboarding_completed?: boolean
        }
        Update: Partial<Database['public']['Tables']['businesses']['Insert']>
        Relationships: []
      }
      business_members: {
        Row: {
          id: string
          business_id: string
          profile_id: string
          role: BusinessMemberRole
          invited_by: string | null
          is_active: boolean
          joined_at: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          profile_id: string
          role?: BusinessMemberRole
          invited_by?: string | null
          is_active?: boolean
          joined_at?: string
        }
        Update: Partial<Database['public']['Tables']['business_members']['Insert']>
        Relationships: []
      }
      customers: {
        Row: {
          id: string
          business_id: string
          profile_id: string | null
          first_name: string
          last_name: string | null
          email: string | null
          phone: string | null
          date_of_birth: string | null
          avatar_url: string | null
          notes: string | null
          is_active: boolean
          joined_at: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          profile_id?: string | null
          first_name: string
          last_name?: string | null
          email?: string | null
          phone?: string | null
          date_of_birth?: string | null
          avatar_url?: string | null
          notes?: string | null
          is_active?: boolean
          joined_at?: string
        }
        Update: Partial<Database['public']['Tables']['customers']['Insert']>
        Relationships: []
      }
      loyalty_programs: {
        Row: {
          id: string
          business_id: string
          name: string
          description: string | null
          type: LoyaltyProgramType
          icon: string | null
          color: string
          rules: Json
          points_per_visit: number | null
          points_per_currency: number | null
          stamps_required: number | null
          expiry_days: number | null
          is_active: boolean
          starts_at: string | null
          ends_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          name: string
          description?: string | null
          type?: LoyaltyProgramType
          icon?: string | null
          color?: string
          rules?: Json
          points_per_visit?: number | null
          points_per_currency?: number | null
          stamps_required?: number | null
          expiry_days?: number | null
          is_active?: boolean
          starts_at?: string | null
          ends_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['loyalty_programs']['Insert']>
        Relationships: []
      }
      loyalty_cards: {
        Row: {
          id: string
          business_id: string
          customer_id: string
          loyalty_program_id: string
          card_number: string
          current_points: number
          current_stamps: number
          tier: string | null
          status: LoyaltyCardStatus
          issued_at: string
          expires_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          customer_id: string
          loyalty_program_id: string
          card_number: string
          current_points?: number
          current_stamps?: number
          tier?: string | null
          status?: LoyaltyCardStatus
          issued_at?: string
          expires_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['loyalty_cards']['Insert']>
        Relationships: []
      }
      loyalty_points: {
        Row: {
          id: string
          loyalty_card_id: string
          balance: number
          lifetime_earned: number
          lifetime_redeemed: number
          last_transaction_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          loyalty_card_id: string
          balance?: number
          lifetime_earned?: number
          lifetime_redeemed?: number
          last_transaction_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['loyalty_points']['Insert']>
        Relationships: []
      }
      point_transactions: {
        Row: {
          id: string
          business_id: string
          loyalty_card_id: string
          customer_id: string
          type: PointTransactionType
          points: number
          balance_after: number
          reference_type: string | null
          reference_id: string | null
          note: string | null
          created_by: string | null
          created_at: string
        }
        Insert: {
          id?: string
          business_id: string
          loyalty_card_id: string
          customer_id: string
          type: PointTransactionType
          points: number
          balance_after: number
          reference_type?: string | null
          reference_id?: string | null
          note?: string | null
          created_by?: string | null
        }
        Update: Partial<Database['public']['Tables']['point_transactions']['Insert']>
        Relationships: []
      }
      qr_codes: {
        Row: {
          id: string
          business_id: string
          customer_id: string
          code: string
          is_active: boolean
          last_scanned_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          customer_id: string
          code: string
          is_active?: boolean
          last_scanned_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['qr_codes']['Insert']>
        Relationships: []
      }
      customer_visits: {
        Row: {
          id: string
          business_id: string
          customer_id: string
          loyalty_card_id: string | null
          business_location_id: string | null
          qr_code_id: string | null
          points_earned: number
          stamps_earned: number
          amount_spent: number | null
          scanned_by: string | null
          visited_at: string
          created_at: string
        }
        Insert: {
          id?: string
          business_id: string
          customer_id: string
          loyalty_card_id?: string | null
          business_location_id?: string | null
          qr_code_id?: string | null
          points_earned?: number
          stamps_earned?: number
          amount_spent?: number | null
          scanned_by?: string | null
          visited_at?: string
        }
        Update: Partial<Database['public']['Tables']['customer_visits']['Insert']>
        Relationships: []
      }
      reward_catalog: {
        Row: {
          id: string
          business_id: string
          loyalty_program_id: string | null
          name: string
          description: string | null
          image_url: string | null
          type: RewardType
          points_cost: number | null
          stamps_cost: number | null
          discount_percent: number | null
          cashback_amount: number | null
          stock_quantity: number | null
          is_active: boolean
          valid_from: string | null
          valid_until: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          loyalty_program_id?: string | null
          name: string
          description?: string | null
          image_url?: string | null
          type?: RewardType
          points_cost?: number | null
          stamps_cost?: number | null
          discount_percent?: number | null
          cashback_amount?: number | null
          stock_quantity?: number | null
          is_active?: boolean
          valid_from?: string | null
          valid_until?: string | null
        }
        Update: Partial<Database['public']['Tables']['reward_catalog']['Insert']>
        Relationships: []
      }
      reward_redemptions: {
        Row: {
          id: string
          business_id: string
          customer_id: string
          reward_id: string
          loyalty_card_id: string | null
          points_spent: number
          stamps_spent: number
          status: RedemptionStatus
          redeemed_by: string | null
          redeemed_at: string | null
          expires_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          customer_id: string
          reward_id: string
          loyalty_card_id?: string | null
          points_spent?: number
          stamps_spent?: number
          status?: RedemptionStatus
          redeemed_by?: string | null
          redeemed_at?: string | null
          expires_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['reward_redemptions']['Insert']>
        Relationships: []
      }
      customer_rewards: {
        Row: {
          id: string
          business_id: string
          customer_id: string
          reward_id: string
          source: CustomerRewardSource
          status: CustomerRewardStatus
          unlocked_at: string
          used_at: string | null
          expires_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          customer_id: string
          reward_id: string
          source?: CustomerRewardSource
          status?: CustomerRewardStatus
          unlocked_at?: string
          used_at?: string | null
          expires_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['customer_rewards']['Insert']>
        Relationships: []
      }
      business_settings: {
        Row: {
          id: string
          business_id: string
          social_links: Json
          notification_preferences: Json
          birthday_rewards_enabled: boolean
          referral_program_enabled: boolean
          default_points_per_currency: number
          default_visit_cooldown_minutes: number
          privacy_settings: Json
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          social_links?: Json
          notification_preferences?: Json
          birthday_rewards_enabled?: boolean
          referral_program_enabled?: boolean
          default_points_per_currency?: number
          default_visit_cooldown_minutes?: number
          privacy_settings?: Json
        }
        Update: Partial<Database['public']['Tables']['business_settings']['Insert']>
        Relationships: []
      }
      promo_codes: {
        Row: {
          id: string
          business_id: string
          code: string
          description: string | null
          discount_percent: number | null
          discount_amount: number | null
          max_redemptions: number | null
          times_redeemed: number
          is_active: boolean
          starts_at: string | null
          expires_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          code: string
          description?: string | null
          discount_percent?: number | null
          discount_amount?: number | null
          max_redemptions?: number | null
          times_redeemed?: number
          is_active?: boolean
          starts_at?: string | null
          expires_at?: string | null
        }
        Update: Partial<Database['public']['Tables']['promo_codes']['Insert']>
        Relationships: []
      }
      birthday_rewards: {
        Row: {
          id: string
          business_id: string
          is_enabled: boolean
          reward_type: BirthdayRewardType
          reward_value: Json
          days_before: number
          valid_days: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          business_id: string
          is_enabled?: boolean
          reward_type?: BirthdayRewardType
          reward_value?: Json
          days_before?: number
          valid_days?: number
        }
        Update: Partial<Database['public']['Tables']['birthday_rewards']['Insert']>
        Relationships: []
      }
      activity_logs: {
        Row: {
          id: string
          business_id: string
          actor_profile_id: string | null
          customer_id: string | null
          action: string
          description: string | null
          metadata: Json
          created_at: string
        }
        Insert: {
          id?: string
          business_id: string
          actor_profile_id?: string | null
          customer_id?: string | null
          action: string
          description?: string | null
          metadata?: Json
        }
        Update: Partial<Database['public']['Tables']['activity_logs']['Insert']>
        Relationships: []
      }
    }
    Views: Record<string, never>
    Functions: Record<string, never>
    Enums: {
      user_role: UserRole
      business_member_role: BusinessMemberRole
      business_category: BusinessCategory
      loyalty_program_type: LoyaltyProgramType
      loyalty_card_status: LoyaltyCardStatus
      point_transaction_type: PointTransactionType
      redemption_status: RedemptionStatus
      customer_reward_source: CustomerRewardSource
      customer_reward_status: CustomerRewardStatus
      birthday_reward_type: BirthdayRewardType
    }
    CompositeTypes: Record<string, never>
  }
}
