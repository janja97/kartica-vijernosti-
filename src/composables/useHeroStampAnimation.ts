import { onMounted, onUnmounted, ref, type Ref } from 'vue'

export type HeroStampPhase = 'idle' | 'falling' | 'impact' | 'burst' | 'glow'

interface UseHeroStampAnimationReturn {
  phase: Ref<HeroStampPhase>
  points: Ref<number>
  cycleCount: Ref<number>
  prefersReducedMotion: Ref<boolean>
}

const PHASE_DURATIONS: Record<Exclude<HeroStampPhase, 'idle'>, number> = {
  falling: 700,
  impact: 450,
  burst: 650,
  glow: 1100,
}

const IDLE_PAUSE_MS = 1600
const START_DELAY_MS = 700

export function useHeroStampAnimation(
  basePoints: number,
  bonusPoints = 40,
): UseHeroStampAnimationReturn {
  const phase = ref<HeroStampPhase>('idle')
  const points = ref(basePoints)
  const cycleCount = ref(0)
  const prefersReducedMotion = ref(false)

  let timeoutId: ReturnType<typeof setTimeout> | undefined

  function goTo(next: HeroStampPhase, delay: number): void {
    timeoutId = setTimeout(() => {
      phase.value = next
      runPhase()
    }, delay)
  }

  function runPhase(): void {
    switch (phase.value) {
      case 'falling':
        cycleCount.value += 1
        goTo('impact', PHASE_DURATIONS.falling)
        break
      case 'impact':
        points.value = basePoints + bonusPoints
        goTo('burst', PHASE_DURATIONS.impact)
        break
      case 'burst':
        goTo('glow', PHASE_DURATIONS.burst)
        break
      case 'glow':
        goTo('idle', PHASE_DURATIONS.glow)
        break
      case 'idle':
        points.value = basePoints
        goTo('falling', IDLE_PAUSE_MS)
        break
    }
  }

  onMounted(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
    prefersReducedMotion.value = mediaQuery.matches

    if (prefersReducedMotion.value) {
      phase.value = 'glow'
      points.value = basePoints + bonusPoints
      cycleCount.value = 1
      return
    }

    goTo('falling', START_DELAY_MS)
  })

  onUnmounted(() => {
    if (timeoutId) clearTimeout(timeoutId)
  })

  return { phase, points, cycleCount, prefersReducedMotion }
}
