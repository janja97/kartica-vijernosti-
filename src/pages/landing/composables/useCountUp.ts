import { ref, watch, type Ref } from 'vue'

export function useCountUp(
  target: Ref<number>,
  trigger: Ref<boolean>,
  durationMs = 1400,
): Ref<number> {
  const current = ref(0)

  watch(trigger, (shouldRun) => {
    if (!shouldRun) return

    const startTime = performance.now()
    const startValue = 0
    const endValue = target.value

    function tick(now: number): void {
      const elapsed = now - startTime
      const progress = Math.min(elapsed / durationMs, 1)
      const eased = 1 - Math.pow(1 - progress, 3)
      current.value = Math.round(startValue + (endValue - startValue) * eased)

      if (progress < 1) {
        requestAnimationFrame(tick)
      }
    }

    requestAnimationFrame(tick)
  })

  return current
}
