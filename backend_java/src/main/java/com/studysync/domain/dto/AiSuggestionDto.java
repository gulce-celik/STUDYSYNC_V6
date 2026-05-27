/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Personalized planner card — reserve session or buddy match hint.
 *
 * <p>Flutter {@code AiSuggestion} ile uyumlu alan adları.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record AiSuggestionDto(
        String id,
        String scope,
        String title,
        String message,
        String courseCode,
        String slotId,
        String slotLabel,
        String dateIso,
        String weekday,
        Integer confidenceScore,
        String reason) {}
