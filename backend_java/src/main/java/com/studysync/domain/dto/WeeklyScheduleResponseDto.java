/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import java.util.List;

/** GET /schedule/weekly yanıt sarmalayıcısı — blok listesi. */
public record WeeklyScheduleResponseDto(List<WeeklyScheduleBlockDto> blocks) {}
