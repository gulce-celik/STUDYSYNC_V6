/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/**
 * Ders özeti — GET /courses listesi.
 *
 * <p>İleride eklenebilir: {@code department}, {@code topics[]} (mobil UI konu chip’leri için),
 * kullanıcının kendi verdiği son oy.
 */
public record CourseDto(
        String code,
        String name,
        Double difficultyRating,
        Integer ratingCount
) {
}
