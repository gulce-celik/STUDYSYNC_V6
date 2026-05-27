/* FILE PURPOSE: API veri tasima modeli (request/response); istemci sozlesmesiyle birebir alanlar. */

package com.studysync.domain.dto;

/**
 * PUT /api/v1/auth/me/planner-preferences — AI planner / study buddy profile inputs.
 *
 * <p>All fields optional; null leaves the stored value unchanged on the server.
 */
public record UpdatePlannerPreferencesRequestDto(String studyGoal, String preferredTime, String preferredDays) {}
