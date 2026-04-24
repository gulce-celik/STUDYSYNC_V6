/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** {@code POST /courses/{code}/rating} gövdesi. */
public record CourseRatingRequestDto(@NotNull @Min(1) @Max(5) Integer rating) {}
