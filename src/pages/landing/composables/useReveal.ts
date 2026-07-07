import { useIntersectionObserver } from '@vueuse/core'
import { ref, type Ref } from 'vue'

export function useReveal(): { target: Ref<HTMLElement | null>; isVisible: Ref<boolean> } {
  const target = ref<HTMLElement | null>(null)
  const isVisible = ref(false)

  useIntersectionObserver(
    target,
    ([entry]) => {
      if (entry?.isIntersecting) {
        isVisible.value = true
      }
    },
    { threshold: 0.15 },
  )

  return { target, isVisible }
}
