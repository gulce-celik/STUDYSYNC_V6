/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import jakarta.validation.constraints.NotBlank;

/** {@code POST /checkin/verify} — QR doğrulama isteği. */
public record CheckInVerifyRequestDto(@NotBlank String reservationId, @NotBlank String qrPayload) {}
