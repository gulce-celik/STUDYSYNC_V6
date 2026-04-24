/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.HomeDashboardResponseDto;
import com.studysync.domain.dto.QuickStatsDto;
import com.studysync.domain.dto.ReservationSummaryDto;
import com.studysync.domain.entity.ReservationRecord;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.mapper.ReservationMapper;
import com.studysync.domain.repository.ReservationRecordRepository;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

/**
 * Ana ekran verisi — skor, yaklaşan rezervasyonlar, özet istatistik.
 *
 * <p><b>Veri kaynakları:</b> {@link com.studysync.domain.repository.ReservationRecordRepository},
 * {@link com.studysync.domain.entity.UserAccount#getResponsibilityScore()}.
 *
 * <p><b>Güvenlik:</b> JWT’den çözülen {@code userId} ile filtre; şimdilik stub kullanıcı yok sayılır.
 */
@Service
public class DashboardService {

    private final ReservationRecordRepository reservationRepository;

    public DashboardService(ReservationRecordRepository reservationRepository) {
        this.reservationRepository = reservationRepository;
    }

    public HomeDashboardResponseDto homeForCurrentUser() {
        // Antigravity Modification: Replaced stub logic to dynamically fetch dashboards based on phase 3 SecurityContext user ID.
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof UserAccount)) {
            throw new IllegalStateException("Authentication missing or invalid");
        }
        UserAccount currentUser = (UserAccount) principal;
        
        List<ReservationRecord> records = reservationRepository.findByUser_IdOrderByDateDescSlotIdAsc(currentUser.getId());
        
        List<ReservationSummaryDto> upcoming = records.stream()
                .filter(r -> "ACTIVE".equals(r.getStatus()) || "PENDING".equals(r.getStatus()))
                .map(ReservationMapper::toSummary)
                .collect(Collectors.toList());

        int activeCount = upcoming.size();
        int score = currentUser.getResponsibilityScore() != null ? currentUser.getResponsibilityScore() : 100;

        return new HomeDashboardResponseDto(score, upcoming, new QuickStatsDto(activeCount, 0));
    }
}
