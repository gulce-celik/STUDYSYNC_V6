/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import java.util.List;

/**
 * Çalışma arkadaşı önerisi — GET /study-buddies/suggestions.
 *
 * <p>{@code matchScore} 0–100; listeler boş olabilir. Gizlilik için {@code name} yerine nickname politikası
 * netleştirin.
 */
public record StudyBuddySuggestionDto(
        String userId,
        String name,
        Integer matchScore,
        List<String> commonCourses,
        List<String> commonTopics
) {
}
