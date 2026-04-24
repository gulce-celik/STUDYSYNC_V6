/* FILE PURPOSE: Entity-DTO donusumleri; API modeli ile persistence modeli arasinda esleme. */

package com.studysync.domain.mapper;

import com.studysync.domain.dto.CourseDto;
import com.studysync.domain.entity.CourseCatalogEntity;

/** {@link CourseCatalogEntity} → {@link CourseDto}. */
public final class CourseMapper {

    private CourseMapper() {}

    public static CourseDto toDto(CourseCatalogEntity e) {
        if (e == null) {
            return null;
        }
        return new CourseDto(e.getCode(), e.getName(), e.getDifficultyRating(), e.getRatingCount());
    }
}
