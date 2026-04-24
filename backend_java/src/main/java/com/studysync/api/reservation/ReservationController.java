/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.reservation;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.CancelReservationRequestDto;
import com.studysync.domain.dto.CreateReservationRequestDto;
import com.studysync.domain.dto.ReservationDetailDto;
import com.studysync.domain.dto.WorkspaceDto;
import com.studysync.domain.service.ReservationService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * /api/v1/reservations — sözleşme: {@code docs/api-contract-v1.md}
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
            @RequestBody(required = false) CancelReservationRequestDto request) {
        if (request == null) {
            return reservationService.cancelReservation(reservationId);
        }
        return reservationService.cancelReservation(reservationId, request.cancelledAt(), request.slotStartAt());
    }
}
