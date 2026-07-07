<script setup lang="ts">
import QRCode from 'qrcode'
import { ref, watchEffect } from 'vue'

const props = defineProps<{
  value: string
}>()

const dataUrl = ref('')

watchEffect(async () => {
  if (!props.value) {
    dataUrl.value = ''
    return
  }
  dataUrl.value = await QRCode.toDataURL(props.value, {
    width: 220,
    margin: 1,
    color: { dark: '#0F172A', light: '#ffffff' },
  })
})
</script>

<template>
  <div class="relative inline-flex">
    <div
      class="absolute inset-0 -z-10 animate-pulse-soft rounded-2xl bg-accent-300 dark:bg-accent-500/40"
    />
    <div class="flex items-center justify-center rounded-2xl bg-white p-4 shadow-soft-lg">
      <img v-if="dataUrl" :src="dataUrl" alt="QR kod" class="h-48 w-48" />
      <div v-else class="h-48 w-48 animate-pulse rounded-lg bg-slate-100" />
    </div>
  </div>
</template>
