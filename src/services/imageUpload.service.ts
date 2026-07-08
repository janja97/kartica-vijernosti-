import { supabase } from '@/supabase/client'

const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024
const ALLOWED_MIME_TYPES = ['image/png', 'image/jpeg', 'image/webp']

export interface UploadImageInput {
  bucket: 'business-logos' | 'reward-images'
  businessId: string
  file: File
  fileName: string
}

function assertValidImage(file: File): void {
  if (!ALLOWED_MIME_TYPES.includes(file.type)) {
    throw new Error('Podržani formati slike su PNG, JPEG i WebP.')
  }
  if (file.size > MAX_FILE_SIZE_BYTES) {
    throw new Error('Slika ne smije biti veća od 5 MB.')
  }
}

function extensionFor(file: File): string {
  return file.type === 'image/png' ? 'png' : file.type === 'image/webp' ? 'webp' : 'jpg'
}

export const imageUploadService = {
  async uploadBusinessScopedImage(input: UploadImageInput): Promise<string> {
    assertValidImage(input.file)

    const path = `${input.businessId}/${input.fileName}.${extensionFor(input.file)}`

    const { error: uploadError } = await supabase.storage
      .from(input.bucket)
      .upload(path, input.file, { upsert: true, contentType: input.file.type })

    if (uploadError) throw uploadError

    const { data } = supabase.storage.from(input.bucket).getPublicUrl(path)
    return `${data.publicUrl}?v=${Date.now()}`
  },
}
