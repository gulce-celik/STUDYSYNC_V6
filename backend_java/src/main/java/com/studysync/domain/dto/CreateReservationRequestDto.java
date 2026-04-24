/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/**
 * {@code POST /reservations} gövdesi — Reserve ekranı ve sözleşme ile uyumlu.
 *
 * <p>{@code reservationType}: {@code INDIVIDUAL} | {@code GROUP} (büyük harf string, JSON’da olduğu gibi).
 */
public record CreateReservationRequestDto(
        @NotBlank String date,
        @NotBlank String slotId,
        @NotBlank String workspaceId,
        @NotBlank String courseCode,
        @NotBlank String reservationType,
        @NotNull Boolean allowStudyBuddy,
        List<String> participantNicknames) {}
