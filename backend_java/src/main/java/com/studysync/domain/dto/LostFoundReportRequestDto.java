/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import jakarta.validation.constraints.NotBlank;

/** {@code POST /lost-found} — kayıp eşya bildirimi. */
public record LostFoundReportRequestDto(@NotBlank String workspaceId, @NotBlank String description) {}
