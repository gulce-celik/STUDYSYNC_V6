/* FILE PURPOSE: Entity-DTO donusumleri; API modeli ile persistence modeli arasinda esleme. */

package com.studysync.domain.mapper;

import com.studysync.domain.dto.WeeklyScheduleBlockDto;
import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.entity.WeeklyScheduleBlockEntity;

/**
 * {@link WeeklyScheduleBlockEntity} ↔ {@link WeeklyScheduleBlockDto}.
 *
 * <p>Alan eşlemesi: {@code dayCode} → {@code day}, {@code blockType} → {@code type}.
 */
public final class WeeklyScheduleMapper {

    private WeeklyScheduleMapper() {}

    public static WeeklyScheduleBlockDto toDto(WeeklyScheduleBlockEntity e) {
        if (e == null) {
            return null;
        }
        return new WeeklyScheduleBlockDto(e.getDayCode(), e.getTimeSlot(), e.getBlockType(), e.getLabel());
    }

    public static void applyDto(WeeklyScheduleBlockEntity e, WeeklyScheduleBlockDto d, UserAccount user) {
        e.setUser(user);
        e.setDayCode(d.day());
        e.setTimeSlot(d.timeSlot());
        e.setBlockType(d.type());
        e.setLabel(d.label());
    }
}
