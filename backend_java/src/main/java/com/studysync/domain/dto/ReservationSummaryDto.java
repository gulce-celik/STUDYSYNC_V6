/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/** Dashboard “yaklaşan rezervasyon” satırı — sözleşmedeki {@code ReservationSummary}. */
public record ReservationSummaryDto(String id, String workspaceId, String date, String slotLabel, String status) {}
