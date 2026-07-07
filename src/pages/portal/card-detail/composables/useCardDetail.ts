import { useQuery, type UseQueryReturnType } from '@tanstack/vue-query'
import { type MaybeRefOrGetter, toValue } from 'vue'

import { customerPortalService } from '@/services/customerPortal.service'
import type { CardDetail } from '@/types/domain/card.types'

export function useCardDetail(
  cardId: MaybeRefOrGetter<string>,
): UseQueryReturnType<CardDetail | null, Error> {
  return useQuery({
    queryKey: ['card-detail', cardId],
    queryFn: () => customerPortalService.getCardDetail(toValue(cardId)),
  })
}
