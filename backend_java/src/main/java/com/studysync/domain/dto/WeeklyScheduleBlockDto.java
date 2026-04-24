/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Haftalık ızgarada tek hücre — day Mon..Fri, timeSlot "09-10" formatı, type lesson|club|busy|null, label opsiyonel.
 *
 * <p>JSON’da null alanları gizlemek için {@link JsonInclude}.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record WeeklyScheduleBlockDto(String day, String timeSlot, String type, String label) {}
