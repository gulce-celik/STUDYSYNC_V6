/* FILE PURPOSE: Tekrar kullanilan is kurali/politika hesabi (iptal skoru, QR dogrulama vb.). */

package com.studysync.domain.policy;

import com.studysync.domain.entity.ReservationRecord;
import java.time.Clock;
import java.time.Instant;
import org.springframework.stereotype.Component;

/**
 * QR yükü ile rezervasyon eşlemesi ve zaman penceresi — {@code POST /checkin/verify}.
 *
 * <p><b>Doğrulama adımları:</b>
 *
 * <ul>
 *   <li>{@link ReservationRecord#getQrPayload()} ile istekteki {@code qrPayload} eşit mi (veya imzalı token parse).
 *   <li>Slot başlangıcı ± tolerans (ör. 15 dk) — {@link Clock} ile test edilebilir saat.
 *   <li>Geç check-in / no-show: {@link ResponsibilityScoreService} çağrıları.
 * </ul>
 */
@Component
public class QrCheckInPolicy {

    private final Clock clock;

    public QrCheckInPolicy(Clock clock) {
        this.clock = clock;
    }

    /** Şimdilik iskelet: gerçek slot zamanı entity’de yoksa genişletme gerekir. */
    public boolean payloadMatchesReservation(ReservationRecord reservation, String qrPayload) {
        if (reservation == null || qrPayload == null) {
            return false;
        }
        return qrPayload.equals(reservation.getQrPayload());
    }

    public Instant now() {
        return clock.instant();
    }
}
