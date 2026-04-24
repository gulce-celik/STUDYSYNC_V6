/* FILE PURPOSE: Tekrar kullanilan is kurali/politika hesabi (iptal skoru, QR dogrulama vb.). */

package com.studysync.domain.policy;

import com.studysync.domain.dto.ActionResultDto;
import java.time.Duration;
import java.time.LocalDateTime;
import org.springframework.stereotype.Component;

/**
 * Rezervasyon iptal zamanına göre sorumluluk puanı ve puan iadesi — {@code docs/api-contract-v1.md} “Cancellation Scoring”.
 *
 * <p><b>Kurallar (özet):</b>
 *
 * <ul>
 *   <li>≥ 24h önce: {@code scoreChange = +3}, {@code pointsRefunded = true}
 *   <li>&lt; 1h önce: {@code scoreChange = -5}, {@code pointsRefunded = false}
 *   <li>arada: {@code scoreChange = 0}, {@code pointsRefunded = null}
 * </ul>
 *
 * <p><b>Kullanım:</b> {@link com.studysync.domain.service.ReservationService#cancelReservation} içinde çağrılır;
 * dönen delta {@link com.studysync.domain.service.ResponsibilityScoreService} ile kullanıcıya uygulanır.
 */
@Component
public class CancellationScoringPolicy {

    public ActionResultDto evaluate(String reservationId, LocalDateTime cancelledAt, LocalDateTime slotStartAt) {
        if (cancelledAt == null || slotStartAt == null) {
            return new ActionResultDto(true, "Cancel accepted (no scoring times) for " + reservationId, null, null);
        }
        final Duration until = Duration.between(cancelledAt, slotStartAt);
        final long hours = until.toHours();
        if (hours >= 24) {
            return new ActionResultDto(true, "Early cancel — bonus", 3, true);
        }
        if (until.toMinutes() < 60) {
            return new ActionResultDto(true, "Late cancel — penalty", -5, false);
        }
        return new ActionResultDto(true, "Mid-window cancel", 0, null);
    }
}
