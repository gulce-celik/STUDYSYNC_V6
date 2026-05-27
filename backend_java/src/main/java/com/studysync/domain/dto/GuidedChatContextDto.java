/* FILE PURPOSE: Python guided-chat request payload. */

package com.studysync.domain.dto;

public record GuidedChatContextDto(
        String courseCode,
        String courseName,
        String topic,
        String studentName,
        String studyGoal,
        Integer difficultyRating,
        String nearestExamCourse,
        String nearestExamDate) {}
