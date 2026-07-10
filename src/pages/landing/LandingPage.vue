<script setup lang="ts">
import AnalyticsPreviewSection from '@/pages/landing/components/AnalyticsPreviewSection.vue'
import CtaSection from '@/pages/landing/components/CtaSection.vue'
import CustomerPreviewSection from '@/pages/landing/components/CustomerPreviewSection.vue'
import DashboardPreviewSection from '@/pages/landing/components/DashboardPreviewSection.vue'
import FaqSection from '@/pages/landing/components/FaqSection.vue'
import FeatureGridSection from '@/pages/landing/components/FeatureGridSection.vue'
import ForBusinessSection from '@/pages/landing/components/ForBusinessSection.vue'
import ForCustomersSection from '@/pages/landing/components/ForCustomersSection.vue'
import HeroSection from '@/pages/landing/components/HeroSection.vue'
import HowItWorksSection from '@/pages/landing/components/HowItWorksSection.vue'
import LandingFooter from '@/pages/landing/components/LandingFooter.vue'
import LandingHeader from '@/pages/landing/components/LandingHeader.vue'
import LogoCloudSection from '@/pages/landing/components/LogoCloudSection.vue'
import StatsStrip from '@/pages/landing/components/StatsStrip.vue'
import TestimonialsSection from '@/pages/landing/components/TestimonialsSection.vue'
import WhySection from '@/pages/landing/components/WhySection.vue'
</script>

<template>
  <div class="min-h-screen">
    <LandingHeader />
    <main>
      <HeroSection />
      <StatsStrip />
      <LogoCloudSection />
      <WhySection />
      <HowItWorksSection />
      <ForBusinessSection />
      <ForCustomersSection />
      <FeatureGridSection />
      <DashboardPreviewSection />
      <CustomerPreviewSection />
      <AnalyticsPreviewSection />
      <TestimonialsSection />
      <FaqSection />
      <CtaSection />
    </main>
    <LandingFooter />
  </div>
</template>
