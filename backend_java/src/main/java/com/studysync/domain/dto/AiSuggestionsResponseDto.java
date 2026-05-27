/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import java.util.List;

/** GET /api/v1/ai/suggestions — reserve cards + buddy card payload. */
public record AiSuggestionsResponseDto(
        List<AiSuggestionDto> reserveSuggestions,
        AiSuggestionDto buddySuggestion,
        String source) {}
