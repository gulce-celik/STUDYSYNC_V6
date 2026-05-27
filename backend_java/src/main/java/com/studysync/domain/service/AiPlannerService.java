/* FILE PURPOSE: AI planner orkestrasyonu — DB verisi + Python AI servisi (+ Java fallback). */

package com.studysync.domain.service;

import com.studysync.domain.dto.AiPlannerContextDto;
import com.studysync.domain.dto.AiPlannerContextDto.ScheduleBlockContextDto;
import com.studysync.domain.dto.AiSuggestionDto;
import com.studysync.domain.dto.AiSuggestionsResponseDto;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.entity.UserCourseRatingEntity;
import com.studysync.domain.entity.WeeklyScheduleBlockEntity;
import com.studysync.domain.planner.AiSuggestionScoringService;
import com.studysync.domain.planner.AiSuggestionScoringService.ExamHint;
import com.studysync.domain.planner.AiSuggestionScoringService.PlannerCandidate;
import com.studysync.domain.planner.PythonAiPlannerClient;
import com.studysync.domain.repository.UserAccountRepository;
import com.studysync.domain.repository.UserCourseRatingRepository;
import com.studysync.domain.repository.WeeklyScheduleBlockRepository;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AiPlannerService {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE;

    private final UserAccountRepository userAccountRepository;
    private final WeeklyScheduleBlockRepository scheduleRepository;
    private final UserCourseRatingRepository ratingRepository;
    private final AiSuggestionScoringService scoringService;
    private final PythonAiPlannerClient pythonAiPlannerClient;

    public AiPlannerService(
            UserAccountRepository userAccountRepository,
            WeeklyScheduleBlockRepository scheduleRepository,
            UserCourseRatingRepository ratingRepository,
            AiSuggestionScoringService scoringService,
            PythonAiPlannerClient pythonAiPlannerClient) {
        this.userAccountRepository = userAccountRepository;
        this.scheduleRepository = scheduleRepository;
        this.ratingRepository = ratingRepository;
        this.scoringService = scoringService;
        this.pythonAiPlannerClient = pythonAiPlannerClient;
    }

    @Transactional(readOnly = true)
    public AiSuggestionsResponseDto getSuggestions(UserAccount currentUser) {
        UserAccount user = userAccountRepository
                .findById(currentUser.getId())
                .orElse(currentUser);

        AiPlannerContextDto context = buildContext(user);
        Optional<AiSuggestionsResponseDto> fromPython = pythonAiPlannerClient.fetchSuggestions(context);
        if (fromPython.isPresent()) {
            return fromPython.get();
        }
        return buildJavaFallback(user);
    }

    private AiPlannerContextDto buildContext(UserAccount user) {
        List<WeeklyScheduleBlockEntity> blocks =
                scheduleRepository.findByUser_IdOrderByDayCodeAscTimeSlotAsc(user.getId());
        List<ScheduleBlockContextDto> scheduleBlocks = blocks.stream()
                .map(b -> new ScheduleBlockContextDto(
                        b.getDayCode(), b.getTimeSlot(), b.getBlockType(), b.getLabel()))
                .toList();

        Map<String, Integer> ratings = new HashMap<>();
        for (UserCourseRatingEntity rating : ratingRepository.findByUser_Id(user.getId())) {
            if (rating.getCourseCode() != null && rating.getRating() != null) {
                ratings.put(rating.getCourseCode().toUpperCase(Locale.ROOT), rating.getRating());
            }
        }

        List<String> enrolled = user.getEnrolledCourses() != null ? user.getEnrolledCourses() : List.of();
        int score = user.getResponsibilityScore() != null ? user.getResponsibilityScore() : 75;

        return new AiPlannerContextDto(
                user.getName() != null ? user.getName() : "Student",
                user.getStudyGoal(),
                user.getPreferredTime(),
                user.getPreferredDays(),
                score,
                enrolled,
                ratings,
                scheduleBlocks);
    }

    private AiSuggestionsResponseDto buildJavaFallback(UserAccount user) {
        List<WeeklyScheduleBlockEntity> blocks =
                scheduleRepository.findByUser_IdOrderByDayCodeAscTimeSlotAsc(user.getId());
        Optional<ExamHint> nearestExam = scoringService.findNearestExam(blocks);
        List<PlannerCandidate> reserveCandidates = scoringService.buildReserveCandidates(user);
        PlannerCandidate buddyCandidate =
                scoringService.buildBuddyCandidate(user, reserveCandidates.getFirst(), nearestExam);

        List<AiSuggestionDto> reserveSuggestions = new ArrayList<>();
        int limit = Math.min(2, reserveCandidates.size());
        for (int i = 0; i < limit; i++) {
            PlannerCandidate candidate = reserveCandidates.get(i);
            reserveSuggestions.add(toDto(candidate, "reserve", defaultReserveMessage(candidate, user)));
        }

        AiSuggestionDto buddySuggestion =
                toDto(buddyCandidate, "buddy", defaultBuddyMessage(buddyCandidate, nearestExam));
        return new AiSuggestionsResponseDto(reserveSuggestions, buddySuggestion, "scoring-fallback");
    }

    private AiSuggestionDto toDto(PlannerCandidate candidate, String scope, String message) {
        return new AiSuggestionDto(
                candidate.id(),
                scope,
                "AI suggestion",
                message,
                candidate.courseCode(),
                candidate.slotId(),
                candidate.slotLabel(),
                candidate.dateIso(),
                candidate.weekday(),
                candidate.score(),
                candidate.scoringReason());
    }

    private static String defaultReserveMessage(PlannerCandidate candidate, UserAccount user) {
        String slotShort = candidate.slotLabel().split(" \\(")[0];
        String goalSuffix = (user.getStudyGoal() != null && !user.getStudyGoal().isBlank())
                ? " Matches your " + user.getStudyGoal() + " goal."
                : "";
        return candidate.weekday()
                + " "
                + slotShort
                + " • Study "
                + candidate.courseCode()
                + " for 2 hours."
                + goalSuffix;
    }

    private static String defaultBuddyMessage(PlannerCandidate candidate, Optional<ExamHint> nearestExam) {
        if (nearestExam.isPresent()) {
            ExamHint exam = nearestExam.get();
            return "AI Suggestion: You have a "
                    + exam.courseCode()
                    + " exam on "
                    + ISO.format(exam.examDate())
                    + ". Find a study buddy for a focused revision session.";
        }
        return "AI Suggestion: Try matching with a buddy for "
                + candidate.courseCode()
                + " around "
                + candidate.weekday()
                + " "
                + candidate.slotLabel().split(" \\(")[0]
                + ".";
    }
}
