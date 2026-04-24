/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/**
 * {@code POST /auth/login} yanıtı — access + refresh + kullanıcı özeti.
 */
public record LoginResponseDto(String accessToken, String refreshToken, UserSummaryDto user) {}
