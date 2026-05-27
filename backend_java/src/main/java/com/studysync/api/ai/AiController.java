/* FILE PURPOSE: HTTP endpoint katmani; AI planner onerilerini istemciye sunar. */

package com.studysync.api.ai;

import com.studysync.domain.dto.AiSuggestionsResponseDto;
import com.studysync.domain.dto.GuidedChatCoursesDto;
import com.studysync.domain.dto.GuidedChatRequestDto;
import com.studysync.domain.dto.GuidedChatResponseDto;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.service.AiGuidedChatService;
import com.studysync.domain.service.AiPlannerService;
import java.util.List;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** GET /api/v1/ai/suggestions — reserve + buddy kartlari icin kisisellestirilmis oneriler. */
@RestController
@RequestMapping("/api/v1/ai")
public class AiController {

    private final AiPlannerService aiPlannerService;
    private final AiGuidedChatService aiGuidedChatService;

    public AiController(AiPlannerService aiPlannerService, AiGuidedChatService aiGuidedChatService) {
        this.aiPlannerService = aiPlannerService;
        this.aiGuidedChatService = aiGuidedChatService;
    }

    @GetMapping("/suggestions")
    public AiSuggestionsResponseDto suggestions(@AuthenticationPrincipal UserAccount currentUser) {
        return aiPlannerService.getSuggestions(currentUser);
    }

    @GetMapping("/guided-chat/courses")
    public GuidedChatCoursesDto guidedChatCourses(@AuthenticationPrincipal UserAccount currentUser) {
        return new GuidedChatCoursesDto(aiGuidedChatService.listAskableCourses(currentUser));
    }

    @PostMapping("/guided-chat")
    public GuidedChatResponseDto guidedChat(
            @AuthenticationPrincipal UserAccount currentUser, @RequestBody GuidedChatRequestDto body) {
        return aiGuidedChatService.chat(currentUser, body);
    }
}
