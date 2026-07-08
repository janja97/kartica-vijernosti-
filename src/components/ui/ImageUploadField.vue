<script setup lang="ts">
import { PhotoIcon } from '@heroicons/vue/24/outline'
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import { imageUploadService } from '@/services/imageUpload.service'
import { getErrorMessage } from '@/utils/getErrorMessage'

const props = defineProps<{
  modelValue: string | null
  bucket: 'business-logos' | 'reward-images'
  businessId: string
  fileName: string
  label: string
}>()

const emit = defineEmits<{
  'update:modelValue': [string | null]
}>()

const { t } = useI18n()
const isUploading = ref(false)
const errorMessage = ref('')
const inputRef = ref<HTMLInputElement | null>(null)

async function handleFileChange(event: Event): Promise<void> {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  errorMessage.value = ''
  isUploading.value = true
  try {
    const url = await imageUploadService.uploadBusinessScopedImage({
      bucket: props.bucket,
      businessId: props.businessId,
      file,
      fileName: props.fileName,
    })
    emit('update:modelValue', url)
  } catch (error) {
    errorMessage.value = getErrorMessage(error)
  } finally {
    isUploading.value = false
    if (inputRef.value) inputRef.value.value = ''
  }
}

function handleRemove(): void {
  emit('update:modelValue', null)
}
</script>

<template>
  <div>
    <label class="mb-1.5 block text-sm font-medium text-slate-700 dark:text-slate-300">
      {{ label }}
    </label>
    <div class="flex items-center gap-4">
      <div
        class="flex h-16 w-16 flex-none items-center justify-center overflow-hidden rounded-xl border border-border bg-surface-sunken"
      >
        <img v-if="modelValue" :src="modelValue" alt="" class="h-full w-full object-cover" />
        <PhotoIcon v-else class="h-6 w-6 text-slate-400" />
      </div>
      <div class="flex flex-col items-start gap-1.5">
        <label
          class="cursor-pointer rounded-lg border border-border px-3 py-1.5 text-xs font-semibold text-slate-700 transition-colors hover:bg-surface-sunken dark:text-slate-200"
        >
          {{
            isUploading
              ? t('common.loading')
              : modelValue
                ? t('common.changeImage')
                : t('common.uploadImage')
          }}
          <input
            ref="inputRef"
            type="file"
            accept="image/png,image/jpeg,image/webp"
            class="hidden"
            :disabled="isUploading"
            @change="handleFileChange"
          />
        </label>
        <button
          v-if="modelValue"
          type="button"
          class="text-xs text-slate-400 transition-colors hover:text-rose-600"
          @click="handleRemove"
        >
          {{ t('common.removeImage') }}
        </button>
      </div>
    </div>
    <p v-if="errorMessage" class="mt-1.5 text-xs text-rose-600 dark:text-rose-400">
      {{ errorMessage }}
    </p>
  </div>
</template>
