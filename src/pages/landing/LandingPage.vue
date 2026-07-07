<script setup lang="ts">
import AudienceSection from '@/pages/landing/components/AudienceSection.vue'
import BenefitsSection from '@/pages/landing/components/BenefitsSection.vue'
import CtaSection from '@/pages/landing/components/CtaSection.vue'
import HeroSection from '@/pages/landing/components/HeroSection.vue'
import HowItWorksSection from '@/pages/landing/components/HowItWorksSection.vue'
import LandingFooter from '@/pages/landing/components/LandingFooter.vue'
import LandingHeader from '@/pages/landing/components/LandingHeader.vue'
import StatsStrip from '@/pages/landing/components/StatsStrip.vue'
</script>

<template>
  <div class="min-h-screen">
    <LandingHeader />
    <main>
      <HeroSection />
      <StatsStrip />
      <AudienceSection />
      <BenefitsSection />
      <HowItWorksSection />
      <CtaSection />
    </main>
    <LandingFooter />
  </div>
</template>
