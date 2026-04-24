/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import java.util.List;

/** PUT /schedule/weekly istek gövdesi — tam liste replace semantiği (istemci ile anlaşın). */
public record WeeklySchedulePutRequestDto(List<WeeklyScheduleBlockDto> blocks) {}
