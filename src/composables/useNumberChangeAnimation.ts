import { type MaybeRefOrGetter, type Ref, ref, toValue, watch } from 'vue'

export function useNumberChangeAnimation(
  value: MaybeRefOrGetter<number>,
  durationMs = 500,
): { isPulsing: Ref<boolean> } {
  const isPulsing = ref(false)
  let timeoutId: ReturnType<typeof setTimeout> | undefined

  watch(
    () => toValue(value),
    (next, previous) => {
      if (previous === undefined || next <= previous) return

      isPulsing.value = false
      requestAnimationFrame(() => {
        isPulsing.value = true
        if (timeoutId) clearTimeout(timeoutId)
        timeoutId = setTimeout(() => {
          isPulsing.value = false
        }, durationMs)
      })
    },
  )

  return { isPulsing }
}
