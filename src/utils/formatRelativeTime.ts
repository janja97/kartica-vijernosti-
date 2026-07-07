export type RelativeTimeUnit = 'now' | 'minutes' | 'hours' | 'days'

export interface RelativeTime {
  unit: RelativeTimeUnit
  n: number
}

export function formatRelativeTime(iso: string): RelativeTime {
  const diffMinutes = Math.round((Date.now() - new Date(iso).getTime()) / 60000)

  if (diffMinutes < 1) return { unit: 'now', n: 0 }
  if (diffMinutes < 60) return { unit: 'minutes', n: diffMinutes }

  const diffHours = Math.round(diffMinutes / 60)
  if (diffHours < 24) return { unit: 'hours', n: diffHours }

  const diffDays = Math.round(diffHours / 24)
  return { unit: 'days', n: diffDays }
}
