/* FILE PURPOSE: Allowed course codes for schedule guided AI chat. */

package com.studysync.domain.dto;

import java.util.List;

public record GuidedChatCoursesDto(List<GuidedChatCourseItemDto> courses) {}
