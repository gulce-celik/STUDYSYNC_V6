/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/** Küçük istatistik kutusu — ana ekran. */
public record QuickStatsDto(int totalReservations, int activeToday) {}
