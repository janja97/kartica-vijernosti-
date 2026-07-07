<script setup lang="ts">
import { CameraIcon } from '@heroicons/vue/24/outline'
import QrScanner from 'qr-scanner'
import QrScannerWorkerPath from 'qr-scanner/qr-scanner-worker.min.js?url'
import { onBeforeUnmount, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { getErrorMessage } from '@/utils/getErrorMessage'

QrScanner.WORKER_PATH = QrScannerWorkerPath

const emit = defineEmits<{
  decode: [code: string]
}>()

const { t } = useI18n()

const videoRef = ref<HTMLVideoElement | null>(null)
const isActive = ref(false)
const errorMessage = ref('')
let scanner: QrScanner | null = null

async function start(): Promise<void> {
  errorMessage.value = ''
  if (!videoRef.value) return

  scanner = new QrScanner(videoRef.value, (result) => emit('decode', result.data), {
    highlightScanRegion: true,
    highlightCodeOutline: true,
  })

  try {
    await scanner.start()
    isActive.value = true
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  }
}

function stop(): void {
  scanner?.stop()
  scanner?.destroy()
  scanner = null
  isActive.value = false
}

defineExpose({ stop })

onBeforeUnmount(() => {
  stop()
})
</script>

<template>
  <div>
    <div
      class="relative mx-auto aspect-square w-full max-w-lg overflow-hidden rounded-3xl border border-border bg-slate-950 shadow-soft-lg"
    >
      <video ref="videoRef" class="h-full w-full object-cover" muted playsinline />

      <div class="pointer-events-none absolute inset-6">
        <span
          class="absolute left-0 top-0 h-10 w-10 rounded-tl-2xl border-l-4 border-t-4 border-accent-400"
        />
        <span
          class="absolute right-0 top-0 h-10 w-10 rounded-tr-2xl border-r-4 border-t-4 border-accent-400"
        />
        <span
          class="absolute bottom-0 left-0 h-10 w-10 rounded-bl-2xl border-b-4 border-l-4 border-accent-400"
        />
        <span
          class="absolute bottom-0 right-0 h-10 w-10 rounded-br-2xl border-b-4 border-r-4 border-accent-400"
        />
        <div
          v-if="isActive"
          class="scan-line absolute inset-x-0 h-0.5 bg-accent-400 shadow-glow-accent"
        />
      </div>
    </div>

    <p v-if="errorMessage" class="mt-3 text-sm text-rose-600 dark:text-rose-400">
      {{ errorMessage }}
    </p>

    <button
      v-if="!isActive"
      type="button"
      class="mx-auto mt-4 flex w-full max-w-lg items-center justify-center gap-2 rounded-lg bg-accent-600 px-4 py-2.5 text-sm font-semibold text-white shadow-soft transition-colors hover:bg-accent-700"
      @click="start"
    >
      <CameraIcon class="h-5 w-5" />
      {{ t('dashboard.scan.startButton') }}
    </button>
  </div>
</template>

<style scoped>
.scan-line {
  animation: scan-line 2.4s ease-in-out infinite;
}

@keyframes scan-line {
  0%,
  100% {
    top: 0;
  }
  50% {
    top: 100%;
  }
}
</style>
