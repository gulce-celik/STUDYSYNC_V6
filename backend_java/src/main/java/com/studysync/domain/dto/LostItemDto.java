/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/**
 * Kayıp eşya kaydı — GET /lost-found.
 *
 * <p>İleride: {@code expiresAt} ISO string (mobil “kalan süre” için); {@code imageUrl}; {@code status}.
 */
public record LostItemDto(
        String id,
        String workspaceId,
        String description,
        String reportedAt
) {
}
