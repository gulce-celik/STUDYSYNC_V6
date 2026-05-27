/* FILE PURPOSE: Python AI servisine gonderilen ogrenci baglami. */

package com.studysync.domain.dto;

import java.util.List;
import java.util.Map;

public record AiPlannerContextDto(
        String studentName,
        String studyGoal,
        String preferredTime,
        String preferredDays,
        int responsibilityScore,
        List<String> enrolledCourses,
        Map<String, Integer> courseRatings,
        List<ScheduleBlockContextDto> scheduleBlocks) {

    public record ScheduleBlockContextDto(String day, String timeSlot, String type, String label) {}
}
