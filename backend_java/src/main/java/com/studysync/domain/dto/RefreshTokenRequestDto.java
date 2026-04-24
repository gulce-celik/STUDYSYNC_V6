/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * {@code POST /api/v1/auth/refresh} — istemciden gelen refresh token (sözleşmeye eklenecek uç).
 */
public record RefreshTokenRequestDto(@NotBlank String refreshToken) {}
