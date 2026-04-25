package com.studysync.domain.dto;

/**
 * Kayıp eşya kaydı — GET /lost-found.
 */
public record LostItemDto(
        String id,
        String workspaceId,
        String description,
        String reportedAt,
        String category,
        String status
) {
}
