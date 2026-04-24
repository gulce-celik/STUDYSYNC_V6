/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.CreateReservationRequestDto;
import com.studysync.domain.dto.ReservationDetailDto;
import com.studysync.domain.dto.WorkspaceDto;
import com.studysync.domain.entity.ReservationRecord;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.mapper.ReservationMapper;
import com.studysync.domain.policy.CancellationScoringPolicy;
import com.studysync.domain.repository.ReservationRecordRepository;
import com.studysync.domain.repository.UserAccountRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.studysync.domain.dto.CancelReservationRequestDto;
import com.studysync.domain.exception.AccessDeniedException;
import com.studysync.domain.exception.ResourceNotFoundException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

/**
 * Rezervasyon alan iş kuralları — şimdilik boş/taş iskelet; gerçek mantığı siz yazacaksınız.
 *
 * <p><b>getWorkspaces(date, slotId, type)</b>
 *
 * <ul>
 *   <li>Veritabanından veya harita servisinden o tarih + slot + tip (bireysel/grup) için masa/oda listesi.
 *   <li>Doluluk: o slotta başka rezervasyon var mı, anlık sensör/operatör güncellemesi varsa birleştirin.
 *   <li>Analiz dokümanındaki Mon/Fri penceresi, anlık masa kuralları burada veya üst katmanda uygulanmalı.
 * </ul>
 *
 * <p><b>createReservation(...)</b> — Controller’dan parse edilen gövde ile:
 *
 * <ul>
 *   <li>Çakışma kontrolü, günlük kota, kullanıcı sorumluluk puanı eşiği.
 *   <li>Persist: {@code Reservation} entity; yanıt {@code ReservationDetailDto} ile aynı alanlar.
 * </ul>
 *
 * <p><b>myReservations()</b> — JWT’den userId okuyup sadece o kullanıcının kayıtlarını döndürün.
 *
 * <p><b>cancelReservation</b> — {@code docs/decision-cancellation-scoring.md} ve {@code api-contract-v1.md}:
 * iptal zamanına göre {@code scoreChange}, {@code pointsRefunded} hesaplayın.
 */
@Service
public class ReservationService {

    private final CancellationScoringPolicy cancellationScoringPolicy;
    private final ReservationRecordRepository reservationRepository;
    private final ResponsibilityScoreService responsibilityScoreService;
    private final ObjectMapper objectMapper;

    public ReservationService(CancellationScoringPolicy cancellationScoringPolicy, 
                              ReservationRecordRepository reservationRepository,
                              ResponsibilityScoreService responsibilityScoreService,
                              ObjectMapper objectMapper) {
        this.cancellationScoringPolicy = cancellationScoringPolicy;
        this.reservationRepository = reservationRepository;
        this.responsibilityScoreService = responsibilityScoreService;
        this.objectMapper = objectMapper;
    }

    public List<WorkspaceDto> getWorkspaces(String date, String slotId, String type) {
        // Antigravity Modification: Reverted to empty list so Flutter app uses its built-in Mock Workspaces.
        return List.of();
    }

    public ReservationDetailDto createReservation(CreateReservationRequestDto request) {
        // Validation: Overlap check
        boolean hasOverlap = reservationRepository.existsByWorkspaceIdAndDateAndSlotIdAndStatusIn(
            request.workspaceId(), request.date(), request.slotId(), List.of("ACTIVE", "PENDING")
        );
        if (hasOverlap) {
            throw new IllegalStateException("This slot is already booked for the selected workspace.");
        }

        // Antigravity Modification: Replaced dummy user hardcoding with real Phase 3 Security Context user extraction!
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof UserAccount)) {
            throw new IllegalStateException("Authentication is missing. Please log in first.");
        }
        UserAccount user = (UserAccount) principal;
        Long defaultUserId = user.getId();

        // Validation: Quota validation (Max 2 reservations per day)
        int dailyReservations = reservationRepository.countByUser_IdAndDateAndStatusIn(
            defaultUserId, request.date(), List.of("ACTIVE", "PENDING", "COMPLETED")
        );
        if (dailyReservations >= 2) {
            throw new IllegalStateException("Daily limit reached. You can only make 2 reservations per day.");
        }

        // Map and Save
        ReservationRecord record = new ReservationRecord();
        record.setUser(user);
        record.setWorkspaceId(request.workspaceId());
        record.setDate(request.date());
        record.setSlotId(request.slotId());
        // For slots like "slot-1", create a default label
        record.setSlotLabel(request.slotId().replace("-", " ").toUpperCase());
        record.setStatus("ACTIVE"); // Auto active for now
        record.setCourseCode(request.courseCode());
        record.setQrPayload("QR_" + System.currentTimeMillis());

        try {
            if (request.participantNicknames() != null && !request.participantNicknames().isEmpty()) {
                record.setParticipantsJson(objectMapper.writeValueAsString(request.participantNicknames()));
            } else {
                record.setParticipantsJson("[]");
            }
        } catch (JsonProcessingException e) {
            record.setParticipantsJson("[]");
        }

        ReservationRecord saved = reservationRepository.save(record);
        return ReservationMapper.toDetail(saved, objectMapper);
    }

    public List<ReservationDetailDto> myReservations() {
        // Antigravity Modification: Implemented user-specific logic to fetch reservation history from Database.
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof UserAccount)) {
            return List.of();
        }
        UserAccount currentUser = (UserAccount) principal;
        List<ReservationRecord> records = reservationRepository.findByUser_IdOrderByDateDescSlotIdAsc(currentUser.getId());
        return records.stream().map(r -> ReservationMapper.toDetail(r, objectMapper)).collect(Collectors.toList());
    }

    public ActionResultDto cancelReservation(String reservationId) {
        return cancelReservation(reservationId, null, null);
    }

    public ActionResultDto cancelReservation(String reservationId, LocalDateTime cancelledAt, LocalDateTime slotStartAt) {
        // Antigravity Modification: Implemented full secure cancellation flow with ownership check and status persistence.
        final ReservationRecord record = reservationRepository.findById(Long.valueOf(reservationId))
                .orElseThrow(() -> new ResourceNotFoundException("Reservation", reservationId));

        // Ownership validation
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (!(principal instanceof UserAccount currentUser) || !record.getUser().getId().equals(currentUser.getId())) {
            throw new AccessDeniedException("You can only cancel your own reservations.");
        }

        if ("CANCELLED".equals(record.getStatus())) {
            return new ActionResultDto(false, "Reservation is already cancelled.", 0, null);
        }

        // Apply policy
        ActionResultDto result = cancellationScoringPolicy.evaluate(reservationId, cancelledAt, slotStartAt);
        
        // Update state
        record.setStatus("CANCELLED");
        reservationRepository.save(record);

        // Apply scoring if applicable
        if (result.scoreChange() != null && result.scoreChange() != 0) {
            responsibilityScoreService.applyDelta(currentUser.getId(), result.scoreChange());
        }

        return result;
    }
}
