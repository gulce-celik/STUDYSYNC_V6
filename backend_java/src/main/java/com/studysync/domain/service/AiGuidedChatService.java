/* FILE PURPOSE: Schedule screen guided AI chat — validates course + proxies to Python. */

package com.studysync.domain.service;

import com.studysync.domain.dto.GuidedChatContextDto;
import com.studysync.domain.dto.GuidedChatCourseItemDto;
import com.studysync.domain.dto.GuidedChatRequestDto;
import com.studysync.domain.dto.GuidedChatResponseDto;
import com.studysync.domain.entity.CourseCatalogEntity;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.entity.UserCourseRatingEntity;
import com.studysync.domain.entity.WeeklyScheduleBlockEntity;
import com.studysync.domain.planner.AiSuggestionScoringService;
import com.studysync.domain.planner.AiSuggestionScoringService.ExamHint;
import com.studysync.domain.planner.PythonAiPlannerClient;
import com.studysync.domain.repository.CourseCatalogRepository;
import com.studysync.domain.repository.UserCourseRatingRepository;
import com.studysync.domain.repository.WeeklyScheduleBlockRepository;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AiGuidedChatService {

    private static final Set<String> VALID_TOPICS = Set.of(
            "exam_study", "youtube", "books", "careers", "projects");
    private static final Pattern COURSE_IN_LABEL =
            Pattern.compile("([A-Z]{2,4})-?(\\d{3})", Pattern.CASE_INSENSITIVE);

    private final CourseCatalogRepository courseCatalogRepository;
    private final WeeklyScheduleBlockRepository scheduleRepository;
    private final UserCourseRatingRepository ratingRepository;
    private final AiSuggestionScoringService scoringService;
    private final PythonAiPlannerClient pythonAiPlannerClient;

    public AiGuidedChatService(
            CourseCatalogRepository courseCatalogRepository,
            WeeklyScheduleBlockRepository scheduleRepository,
            UserCourseRatingRepository ratingRepository,
            AiSuggestionScoringService scoringService,
            PythonAiPlannerClient pythonAiPlannerClient) {
        this.courseCatalogRepository = courseCatalogRepository;
        this.scheduleRepository = scheduleRepository;
        this.ratingRepository = ratingRepository;
        this.scoringService = scoringService;
        this.pythonAiPlannerClient = pythonAiPlannerClient;
    }

    /** Catalog courses the user may ask about (catalog ∩ schedule ∪ enrolled), with display names. */
    @Transactional(readOnly = true)
    public List<GuidedChatCourseItemDto> listAskableCourses(UserAccount currentUser) {
        Set<String> allowed = collectAllowedCourseCodes(currentUser);
        return courseCatalogRepository.findAll().stream()
                .filter(c -> c.getCode() != null && !c.getCode().isBlank())
                .filter(c -> allowed.contains(normalizeCode(c.getCode())))
                .map(c -> new GuidedChatCourseItemDto(
                        normalizeCode(c.getCode()),
                        c.getName() != null && !c.getName().isBlank() ? c.getName() : c.getCode()))
                .sorted(Comparator.comparing(GuidedChatCourseItemDto::code))
                .toList();
    }

    @Transactional(readOnly = true)
    public GuidedChatResponseDto chat(UserAccount currentUser, GuidedChatRequestDto request) {
        if (request == null || request.courseCode() == null || request.courseCode().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "courseCode is required");
        }
        String topic = request.topic() != null ? request.topic().trim() : "";
        if (!VALID_TOPICS.contains(topic)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid topic");
        }

        String courseCode = normalizeCode(request.courseCode());
        CourseCatalogEntity catalog = resolveCatalogCourse(courseCode)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown course"));

        if (!collectAllowedCourseCodes(currentUser).contains(courseCode)) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Add this course to your schedule or enrolled list first");
        }

        GuidedChatContextDto ctx = buildContext(currentUser, catalog, courseCode, topic);
        Optional<GuidedChatResponseDto> fromPython = pythonAiPlannerClient.fetchGuidedChat(ctx);
        return fromPython.orElseGet(() -> javaFallback(catalog, courseCode, topic));
    }

    private Set<String> collectAllowedCourseCodes(UserAccount user) {
        Set<String> allowed = new HashSet<>();
        if (user.getEnrolledCourses() != null) {
            for (String c : user.getEnrolledCourses()) {
                if (c != null && !c.isBlank()) {
                    allowed.add(normalizeCode(c));
                }
            }
        }
        List<WeeklyScheduleBlockEntity> blocks =
                scheduleRepository.findByUser_IdOrderByDayCodeAscTimeSlotAsc(user.getId());
        for (WeeklyScheduleBlockEntity block : blocks) {
            String extracted = extractCourseCode(block.getLabel());
            if (extracted != null) {
                allowed.add(extracted);
            }
        }
        return allowed;
    }

    private GuidedChatContextDto buildContext(
            UserAccount user, CourseCatalogEntity catalog, String courseCode, String topic) {
        List<WeeklyScheduleBlockEntity> blocks =
                scheduleRepository.findByUser_IdOrderByDayCodeAscTimeSlotAsc(user.getId());
        Optional<ExamHint> nearestExam = scoringService.findNearestExam(blocks);

        Integer userRating = null;
        for (UserCourseRatingEntity rating : ratingRepository.findByUser_Id(user.getId())) {
            if (rating.getCourseCode() != null
                    && normalizeCode(rating.getCourseCode()).equals(courseCode)
                    && rating.getRating() != null) {
                userRating = rating.getRating();
                break;
            }
        }

        String examCourse = null;
        String examDate = null;
        if (nearestExam.isPresent()) {
            examCourse = nearestExam.get().courseCode();
            examDate = nearestExam.get().examDate().toString();
        }

        return new GuidedChatContextDto(
                courseCode,
                catalog.getName(),
                topic,
                user.getName() != null ? user.getName() : "Student",
                user.getStudyGoal(),
                userRating,
                examCourse,
                examDate);
    }

    private GuidedChatResponseDto javaFallback(CourseCatalogEntity catalog, String courseCode, String topic) {
        String name = catalog.getName() != null ? catalog.getName() : courseCode;
        String message = switch (topic) {
            case "exam_study" -> "Review " + courseCode + " (" + name + ") weekly and practice past exam questions in timed blocks.";
            case "youtube" -> "Search YouTube for " + name + " lecture playlists and follow one structured series.";
            case "books" -> "Use the official syllabus textbook for " + courseCode + " and one exercise-heavy reference.";
            case "careers" -> "Explore internships that list " + courseCode + " skills; talk to campus career office.";
            case "projects" -> "Build a small project applying one major " + courseCode + " topic; document design and results.";
            default -> "Study guidance for " + courseCode + ".";
        };
        return new GuidedChatResponseDto(message, "scoring-fallback", topic, courseCode);
    }

    private Optional<CourseCatalogEntity> resolveCatalogCourse(String normalizedCode) {
        return courseCatalogRepository.findAll().stream()
                .filter(c -> c.getCode() != null && normalizeCode(c.getCode()).equals(normalizedCode))
                .findFirst();
    }

    private static String normalizeCode(String code) {
        return code.trim().toUpperCase(Locale.ROOT).replace("-", "");
    }

    private static String extractCourseCode(String label) {
        if (label == null || label.isBlank()) {
            return null;
        }
        if (label.startsWith("EXAM:")) {
            String[] parts = label.split(":");
            if (parts.length >= 2 && !parts[1].isBlank()) {
                return normalizeCode(parts[1]);
            }
        }
        Matcher m = COURSE_IN_LABEL.matcher(label.toUpperCase(Locale.ROOT));
        if (!m.find()) {
            return null;
        }
        return m.group(1) + m.group(2);
    }
}
