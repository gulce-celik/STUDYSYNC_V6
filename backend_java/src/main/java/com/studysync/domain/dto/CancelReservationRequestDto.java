package com.studysync.domain.dto;

import java.time.LocalDateTime;

/**
 * Rezervasyon iptali için opsiyonel zaman bilgileri.
 */
public record CancelReservationRequestDto(
    LocalDateTime cancelledAt,
    LocalDateTime slotStartAt
) {}
