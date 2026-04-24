/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/**
 * Genel komut yanıtı — iptal, oylama, raporlama uçlarında kullanılır.
 *
 * <p>Alanlar: {@code success}, kullanıcıya mesaj; {@code scoreChange} sorumluluk puanı deltas;
 * {@code pointsRefunded} rezervasyon puan iadesi (Boolean / null = belirsiz). Sözleşme: api-contract-v1.
 */
public record ActionResultDto(
        Boolean success,
        String message,
        Integer scoreChange,
        Boolean pointsRefunded
) {
}
