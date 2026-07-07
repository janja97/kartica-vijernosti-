<script setup lang="ts">
import DashboardSidebar from '@/pages/dashboard/components/DashboardSidebar.vue'
</script>

<template>
  <div class="flex min-h-screen bg-surface-sunken">
    <DashboardSidebar />
    <div class="flex min-w-0 flex-1 flex-col">
      <RouterView />
    </div>
  </div>
</template>
