/* FILE PURPOSE: SQL + scoring tabanli aday uretimi; Gemini oncesi deterministik katman. */

package com.studysync.domain.planner;

import com.studysync.config.TimeConfig;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.entity.UserCourseRatingEntity;
import com.studysync.domain.entity.WeeklyScheduleBlockEntity;
import com.studysync.domain.repository.UserCourseRatingRepository;
import com.studysync.domain.repository.WeeklyScheduleBlockRepository;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;

@Service
public class AiSuggestionScoringService {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE;
    private static final Pattern COURSE_IN_LABEL = Pattern.compile("([A-Z]{2,4})-?(\\d{3})");

    private static final List<String> WEEKDAY_ORDER = List.of("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun");

    private static final Map<String, SlotMapping> SCHEDULE_TO_RESERVATION = Map.ofEntries(
            Map.entry("09-10", new SlotMapping("slot-2", "09:00 - 11:00 (Class Time)")),
            Map.entry("10-11", new SlotMapping("slot-2", "09:00 - 11:00 (Class Time)")),
            Map.entry("11-12", new SlotMapping("slot-3", "11:00 - 13:00 (Class Time)")),
            Map.entry("12-13", new SlotMapping("slot-3", "11:00 - 13:00 (Class Time)")),
            Map.entry("13-14", new SlotMapping("slot-4", "13:00 - 15:00 (Class Time)")),
            Map.entry("14-15", new SlotMapping("slot-4", "13:00 - 15:00 (Class Time)")),
            Map.entry("15-16", new SlotMapping("slot-5", "15:00 - 17:00 (Class Time)")),
            Map.entry("16-17", new SlotMapping("slot-5", "15:00 - 17:00 (Class Time)")),
            Map.entry("17-18", new SlotMapping("slot-6", "17:00 - 20:00 (Evening 1)")),
            Map.entry("18-19", new SlotMapping("slot-6", "17:00 - 20:00 (Evening 1)")),
            Map.entry("19-20", new SlotMapping("slot-7", "20:00 - 23:00 (Evening 2)")));

    private final WeeklyScheduleBlockRepository scheduleRepository;
    private final UserCourseRatingRepository ratingRepository;

    public AiSuggestionScoringService(
            WeeklyScheduleBlockRepository scheduleRepository, UserCourseRatingRepository ratingRepository) {
        this.scheduleRepository = scheduleRepository;
        this.ratingRepository = ratingRepository;
    }

    public List<PlannerCandidate> buildReserveCandidates(UserAccount user) {
        List<WeeklyScheduleBlockEntity> blocks =
                scheduleRepository.findByUser_IdOrderByDayCodeAscTimeSlotAsc(user.getId());
        Set<String> occupied = new HashSet<>();
        for (WeeklyScheduleBlockEntity block : blocks) {
            if (block.getDayCode() != null && block.getTimeSlot() != null) {
                occupied.add(block.getDayCode() + "|" + block.getTimeSlot());
            }
        }

        Optional<ExamHint> nearestExam = findNearestExam(blocks);
        Map<String, Integer> ratings = loadRatings(user.getId());
        String priorityCourse = pickPriorityCourse(user, blocks, ratings, nearestExam);

        List<String> dayCandidates = preferredDayCandidates(user.getPreferredDays());
        List<String> slotCandidates = preferredSlotCandidates(user.getPreferredTime());

        LocalDate today = LocalDate.now(TimeConfig.CAMPUS_ZONE);
        List<PlannerCandidate> scored = new ArrayList<>();

        for (String day : dayCandidates) {
            for (String scheduleSlot : slotCandidates) {
                if (occupied.contains(day + "|" + scheduleSlot)) {
                    continue;
                }
                SlotMapping mapping = SCHEDULE_TO_RESERVATION.get(scheduleSlot);
                if (mapping == null) {
                    continue;
                }
                LocalDate date = nextDateForDay(day, today);
                int score = scoreReserveSlot(user, priorityCourse, day, scheduleSlot, date, nearestExam, ratings);
                String reason = buildScoringReason(user, priorityCourse, nearestExam, ratings);
                scored.add(new PlannerCandidate(
                        "reserve-" + day + "-" + scheduleSlot + "-" + priorityCourse,
                        priorityCourse,
                        mapping.slotId(),
                        mapping.slotLabel(),
                        ISO.format(date),
                        day,
                        score,
                        reason));
            }
        }

        scored.sort(Comparator.comparingInt(PlannerCandidate::score).reversed());
        if (scored.isEmpty()) {
            LocalDate fallbackDate = nextDateForDay("Tue", today);
            scored.add(new PlannerCandidate(
                    "reserve-fallback",
                    priorityCourse,
                    "slot-4",
                    "13:00 - 15:00 (Class Time)",
                    ISO.format(fallbackDate),
                    "Tue",
                    40,
                    "Default 2h study block when no free grid slot matches your preferences."));
        }
        return scored.stream().limit(5).toList();
    }

    public PlannerCandidate buildBuddyCandidate(UserAccount user, PlannerCandidate topReserve, Optional<ExamHint> exam) {
        String course = exam.map(ExamHint::courseCode).orElse(topReserve.courseCode());
        String weekday = exam.map(e -> weekdayFromDate(e.examDate())).orElse(topReserve.weekday());
        String dateIso = exam.map(e -> ISO.format(e.examDate())).orElse(topReserve.dateIso());
        String slotId = topReserve.slotId();
        String slotLabel = topReserve.slotLabel();
        int score = exam.isPresent() ? 92 : Math.min(88, topReserve.score() + 5);
        String reason = exam.isPresent()
                ? "Upcoming exam focus — match with peers revising the same course."
                : "Shared course and overlapping study window with your planner suggestion.";
        return new PlannerCandidate(
                "buddy-" + course + "-" + weekday,
                course,
                slotId,
                slotLabel,
                dateIso,
                weekday,
                score,
                reason);
    }

    public Optional<ExamHint> findNearestExam(List<WeeklyScheduleBlockEntity> blocks) {
        LocalDate today = LocalDate.now(TimeConfig.CAMPUS_ZONE);
        ExamHint best = null;
        for (WeeklyScheduleBlockEntity block : blocks) {
            ExamHint parsed = parseExamLabel(block.getLabel());
            if (parsed == null || parsed.examDate().isBefore(today)) {
                continue;
            }
            if (best == null || parsed.examDate().isBefore(best.examDate())) {
                best = parsed;
            }
        }
        return Optional.ofNullable(best);
    }

    private Map<String, Integer> loadRatings(Long userId) {
        Map<String, Integer> ratings = new HashMap<>();
        for (UserCourseRatingEntity rating : ratingRepository.findByUser_Id(userId)) {
            if (rating.getCourseCode() != null && rating.getRating() != null) {
                ratings.put(rating.getCourseCode().toUpperCase(Locale.ROOT), rating.getRating());
            }
        }
        return ratings;
    }

    private String pickPriorityCourse(
            UserAccount user,
            List<WeeklyScheduleBlockEntity> blocks,
            Map<String, Integer> ratings,
            Optional<ExamHint> nearestExam) {
        if (nearestExam.isPresent() && nearestExam.get().courseCode() != null) {
            return nearestExam.get().courseCode();
        }
        List<String> enrolled = normalizeCourseCodes(user.getEnrolledCourses());
        if (!enrolled.isEmpty()) {
            Optional<String> hardest = enrolled.stream()
                    .filter(ratings::containsKey)
                    .max(Comparator.comparingInt(ratings::get));
            if (hardest.isPresent()) {
                return hardest.get();
            }
            return enrolled.getFirst();
        }
        for (WeeklyScheduleBlockEntity block : blocks) {
            String extracted = extractCourseCode(block.getLabel());
            if (extracted != null) {
                return extracted;
            }
        }
        return "CSE344";
    }

    private int scoreReserveSlot(
            UserAccount user,
            String course,
            String day,
            String scheduleSlot,
            LocalDate date,
            Optional<ExamHint> nearestExam,
            Map<String, Integer> ratings) {
        int score = 50;
        if (nearestExam.isPresent()) {
            long days = ChronoUnit.DAYS.between(LocalDate.now(TimeConfig.CAMPUS_ZONE), nearestExam.get().examDate());
            if (days <= 7) {
                score += 25;
            } else if (days <= 14) {
                score += 12;
            }
            if (course.equalsIgnoreCase(nearestExam.get().courseCode())) {
                score += 10;
            }
        }
        Integer rating = ratings.get(course.toUpperCase(Locale.ROOT));
        if (rating != null) {
            score += Math.max(0, rating - 1) * 5;
        }
        if (matchesPreferredTime(user.getPreferredTime(), scheduleSlot)) {
            score += 8;
        }
        if (matchesPreferredDays(user.getPreferredDays(), day)) {
            score += 6;
        }
        if (user.getStudyGoal() != null && !user.getStudyGoal().isBlank()) {
            score += 4;
        }
        Integer responsibility = user.getResponsibilityScore();
        if (responsibility != null && responsibility < 75) {
            score += 3;
        }
        return Math.min(100, score);
    }

    private String buildScoringReason(
            UserAccount user, String course, Optional<ExamHint> nearestExam, Map<String, Integer> ratings) {
        List<String> parts = new ArrayList<>();
        nearestExam.ifPresent(exam -> parts.add("Exam " + exam.courseCode() + " on " + ISO.format(exam.examDate())));
        Integer rating = ratings.get(course.toUpperCase(Locale.ROOT));
        if (rating != null) {
            parts.add("your difficulty rating " + rating + "/5");
        }
        if (user.getStudyGoal() != null && !user.getStudyGoal().isBlank()) {
            parts.add("goal: " + user.getStudyGoal());
        }
        if (parts.isEmpty()) {
            return "Free slot aligned with your weekly schedule.";
        }
        return String.join("; ", parts);
    }

    private static boolean matchesPreferredTime(String preferredTime, String scheduleSlot) {
        if (preferredTime == null || preferredTime.isBlank()) {
            return false;
        }
        return preferredSlotCandidates(preferredTime).contains(scheduleSlot);
    }

    private static boolean matchesPreferredDays(String preferredDays, String day) {
        if (preferredDays == null || preferredDays.isBlank()) {
            return true;
        }
        if ("weekend".equalsIgnoreCase(preferredDays.trim())) {
            return "Fri".equals(day) || "Sat".equals(day) || "Sun".equals(day);
        }
        return true;
    }

    private static List<String> preferredSlotCandidates(String preferredTime) {
        if (preferredTime == null) {
            return List.of("14-15", "13-14", "11-12");
        }
        return switch (preferredTime.trim().toLowerCase(Locale.ROOT)) {
            case "morning" -> List.of("09-10", "10-11", "11-12");
            case "afternoon" -> List.of("13-14", "14-15", "15-16");
            case "evening" -> List.of("17-18", "18-19", "19-20");
            default -> List.of("14-15", "13-14", "11-12");
        };
    }

    private static List<String> preferredDayCandidates(String preferredDays) {
        if (preferredDays != null && "weekend".equalsIgnoreCase(preferredDays.trim())) {
            return List.of("Fri", "Thu", "Wed");
        }
        return List.of("Tue", "Wed", "Thu", "Fri", "Mon");
    }

    private static LocalDate nextDateForDay(String shortDay, LocalDate today) {
        int targetDow = dayOfWeekValue(shortDay);
        int delta = targetDow - today.getDayOfWeek().getValue();
        if (delta <= 0) {
            delta += 7;
        }
        return today.plusDays(delta);
    }

    private static int dayOfWeekValue(String shortDay) {
        return switch (shortDay) {
            case "Mon" -> 1;
            case "Tue" -> 2;
            case "Wed" -> 3;
            case "Thu" -> 4;
            case "Fri" -> 5;
            case "Sat" -> 6;
            case "Sun" -> 7;
            default -> 2;
        };
    }

    private static String weekdayFromDate(LocalDate date) {
        int idx = date.getDayOfWeek().getValue() - 1;
        if (idx < 0 || idx >= WEEKDAY_ORDER.size()) {
            return "Tue";
        }
        return WEEKDAY_ORDER.get(idx);
    }

    private static ExamHint parseExamLabel(String label) {
        if (label == null || !label.startsWith("EXAM:")) {
            return null;
        }
        String[] parts = label.split(":");
        if (parts.length < 3) {
            return null;
        }
        String code = parts[1].trim().toUpperCase(Locale.ROOT);
        if (code.isEmpty()) {
            return null;
        }
        String rawDate = parts[2].trim();
        if (rawDate.length() >= 10) {
            rawDate = rawDate.substring(0, 10);
        }
        LocalDate examDate = LocalDate.parse(rawDate);
        return new ExamHint(code, examDate);
    }

    private static String extractCourseCode(String label) {
        if (label == null || label.isBlank()) {
            return null;
        }
        Matcher matcher = COURSE_IN_LABEL.matcher(label.toUpperCase(Locale.ROOT));
        if (!matcher.find()) {
            return null;
        }
        return matcher.group(1) + matcher.group(2);
    }

    private static List<String> normalizeCourseCodes(List<String> codes) {
        if (codes == null || codes.isEmpty()) {
            return List.of();
        }
        List<String> normalized = new ArrayList<>();
        for (String code : codes) {
            if (code == null || code.isBlank()) {
                continue;
            }
            normalized.add(code.trim().toUpperCase(Locale.ROOT));
        }
        return normalized;
    }

    public record PlannerCandidate(
            String id,
            String courseCode,
            String slotId,
            String slotLabel,
            String dateIso,
            String weekday,
            int score,
            String scoringReason) {}

    public record ExamHint(String courseCode, LocalDate examDate) {}

    private record SlotMapping(String slotId, String slotLabel) {}
}
