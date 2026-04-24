/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * {@code POST /api/v1/auth/login} istek gövdesi — sözleşme: {@code docs/api-contract-v1.md}.
 */
public record LoginRequestDto(@NotBlank @Email String email, @NotBlank String password) {}
