/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.StudyBuddySuggestionDto;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.repository.UserAccountRepository;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Çalışma arkadaşı önerileri — enrolled course overlap + year proximity scoring.
 *
 * <p>Gemini kart metni {@link AiPlannerService} tarafindan uretilir; burada eslesme listesi SQL tabanlidir.
 */
@Service
public class StudyBuddyService {

    private final UserAccountRepository userAccountRepository;

    public StudyBuddyService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    @Transactional(readOnly = true)
    public List<StudyBuddySuggestionDto> getSuggestions(String courseCode, String slotId) {
        Object principal =
                org.springframework.security.core.context.SecurityContextHolder.getContext()
                        .getAuthentication()
                        .getPrincipal();
        if (!(principal instanceof UserAccount currentUser)) {
            return List.of();
        }

        String normalizedCourse = normalizeCourse(courseCode);
        List<UserAccount> others = userAccountRepository.findByIdNot(currentUser.getId());
        List<ScoredBuddy> scored = new ArrayList<>();

        for (UserAccount candidate : others) {
            List<String> common = commonCourses(currentUser, candidate);
            if (common.isEmpty()) {
                continue;
            }
            if (normalizedCourse != null
                    && !normalizedCourse.isBlank()
                    && common.stream().noneMatch(c -> c.equalsIgnoreCase(normalizedCourse))) {
                continue;
            }
            int matchScore = scoreMatch(currentUser, candidate, common, normalizedCourse);
            if (matchScore < 55) {
                continue;
            }
            String displayName = candidate.getNickname() != null && !candidate.getNickname().isBlank()
                    ? candidate.getNickname()
                    : firstName(candidate.getName());
            scored.add(new ScoredBuddy(
                    new StudyBuddySuggestionDto(
                            String.valueOf(candidate.getId()),
                            displayName,
                            matchScore,
                            common,
                            List.of("Shared course focus", slotId != null ? "Slot " + slotId : "Flexible timing")),
                    matchScore));
        }

        scored.sort(Comparator.comparingInt(ScoredBuddy::matchScore).reversed());
        return scored.stream().limit(10).map(ScoredBuddy::dto).toList();
    }

    private static List<String> commonCourses(UserAccount current, UserAccount other) {
        Set<String> mine = new HashSet<>(normalizeList(current.getEnrolledCourses()));
        List<String> shared = new ArrayList<>();
        for (String code : normalizeList(other.getEnrolledCourses())) {
            if (mine.contains(code)) {
                shared.add(code);
            }
        }
        return shared.stream().distinct().sorted().toList();
    }

    private static int scoreMatch(
            UserAccount current, UserAccount candidate, List<String> common, String focusCourse) {
        int score = 50 + Math.min(30, common.size() * 12);
        if (focusCourse != null
                && !focusCourse.isBlank()
                && common.stream().anyMatch(c -> c.equalsIgnoreCase(focusCourse))) {
            score += 15;
        }
        if (current.getYear() != null
                && candidate.getYear() != null
                && current.getYear().equals(candidate.getYear())) {
            score += 8;
        }
        if (current.getDepartmentId() != null
                && current.getDepartmentId().equalsIgnoreCase(candidate.getDepartmentId())) {
            score += 5;
        }
        return Math.min(98, score);
    }

    private static String normalizeCourse(String courseCode) {
        if (courseCode == null || courseCode.isBlank()) {
            return null;
        }
        return courseCode.trim().toUpperCase(Locale.ROOT);
    }

    private static List<String> normalizeList(List<String> codes) {
        if (codes == null) {
            return List.of();
        }
        return codes.stream()
                .filter(c -> c != null && !c.isBlank())
                .map(c -> c.trim().toUpperCase(Locale.ROOT))
                .distinct()
                .toList();
    }

    private static String firstName(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "Student";
        }
        String[] parts = fullName.trim().split("\\s+");
        return parts[0];
    }

    private record ScoredBuddy(StudyBuddySuggestionDto dto, int matchScore) {}
}
