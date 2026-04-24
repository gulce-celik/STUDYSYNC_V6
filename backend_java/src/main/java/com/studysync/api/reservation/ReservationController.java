/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.reservation;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.CreateReservationRequestDto;
import com.studysync.domain.dto.ReservationDetailDto;
import com.studysync.domain.dto.WorkspaceDto;
import com.studysync.domain.service.ReservationService;
import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * /api/v1/reservations — sözleşme: {@code docs/api-contract-v1.md}
 *
 * <p>İçerik nasıl olmalı:
 *
 * <ul>
 *   <li>{@code createReservation}: {@code @RequestBody} yerine typed {@code CreateReservationRequestDto}
 *       (date, slotId, workspaceId, courseCode, reservationType, allowStudyBuddy, participantNicknames).
 *   <li>Tüm mutasyonlarda güvenlik: sadece giriş yapmış kullanıcı; workspace’i başkasının iptal edememesi.
 *   <li>{@code cancelReservation}: isteğe bağlı gövde {@code cancelledAt}, {@code slotStartAt} ISO-8601 string;
 *       parse hatalarında 400.
 * </ul>
 */
@RestController
@RequestMapping("/api/v1/reservations")
public class ReservationController {
    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    @GetMapping("/workspaces")
    public List<WorkspaceDto> getWorkspaces(
            @RequestParam String date,
            @RequestParam String slotId,
            @RequestParam String type) {
        return reservationService.getWorkspaces(date, slotId, type);
    }

    @PostMapping
    public ReservationDetailDto createReservation(@Valid @RequestBody CreateReservationRequestDto request) {
        return reservationService.createReservation(request);
    }

    @GetMapping("/me")
    public List<ReservationDetailDto> myReservations() {
        return reservationService.myReservations();
    }

    @PostMapping("/{reservationId}/cancel")
    public ActionResultDto cancelReservation(
            @PathVariable String reservationId,
            @RequestBody(required = false) Map<String, String> payload) {
        if (payload == null || !payload.containsKey("cancelledAt") || !payload.containsKey("slotStartAt")) {
            return reservationService.cancelReservation(reservationId);
        }
        final LocalDateTime cancelledAt = LocalDateTime.parse(payload.get("cancelledAt"));
        final LocalDateTime slotStartAt = LocalDateTime.parse(payload.get("slotStartAt"));
        return reservationService.cancelReservation(reservationId, cancelledAt, slotStartAt);
    }
}
