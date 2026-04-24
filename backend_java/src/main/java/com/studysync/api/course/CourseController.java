/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.course;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.CourseDto;
import com.studysync.domain.dto.CourseRatingRequestDto;
import com.studysync.domain.service.CourseService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * GET /api/v1/courses — POST /api/v1/courses/{courseCode}/rating
 *
 * <p>İçerik: {@code rating} 1–5 doğrulaması; yetkisiz kullanıcı engeli; ileride {@code @RequestBody RatingRequestDto}.
 */
@RestController
@RequestMapping("/api/v1/courses")
public class CourseController {
    private final CourseService courseService;

    public CourseController(CourseService courseService) {
        this.courseService = courseService;
    }

    @GetMapping
    public List<CourseDto> getCourses() {
        return courseService.getCourses();
    }

    @PostMapping("/{courseCode}/rating")
    public ActionResultDto rateCourse(@PathVariable String courseCode, @Valid @RequestBody CourseRatingRequestDto body) {
        return courseService.rateCourse(courseCode, body.rating());
    }
}
