/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.buddy;

import com.studysync.domain.dto.StudyBuddySuggestionDto;
import com.studysync.domain.service.StudyBuddyService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * GET /api/v1/study-buddies/suggestions?courseCode=&slotId=
 *
 * <p>İçerik: kullanıcı oturumuna göre kişiselleştirilmiş liste; rate limiting düşünün.
 */
@RestController
@RequestMapping("/api/v1/study-buddies")
public class StudyBuddyController {
    private final StudyBuddyService studyBuddyService;

    public StudyBuddyController(StudyBuddyService studyBuddyService) {
        this.studyBuddyService = studyBuddyService;
    }

    @GetMapping("/suggestions")
    public List<StudyBuddySuggestionDto> suggestions(
            @RequestParam String courseCode,
            @RequestParam String slotId) {
        return studyBuddyService.getSuggestions(courseCode, slotId);
    }
}
