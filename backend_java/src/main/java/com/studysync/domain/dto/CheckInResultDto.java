/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/** Check-in yanıtı — sözleşme: success, message; ileride scoreChange genişletilebilir. */
public record CheckInResultDto(boolean success, String message) {}
