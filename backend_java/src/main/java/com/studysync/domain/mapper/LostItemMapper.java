/* FILE PURPOSE: Entity-DTO donusumleri; API modeli ile persistence modeli arasinda esleme. */

package com.studysync.domain.mapper;

import com.studysync.domain.dto.LostItemDto;
import com.studysync.domain.entity.LostItemRecord;
import java.time.format.DateTimeFormatter;

/**
 * {@link LostItemRecord} → {@link LostItemDto}; {@code reportedAt} ISO-8601 string (Flutter parse).
 */
public final class LostItemMapper {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_INSTANT;

    private LostItemMapper() {}

    public static LostItemDto toDto(LostItemRecord r) {
        if (r == null) {
            return null;
        }
        final String at = r.getReportedAt() != null ? ISO.format(r.getReportedAt()) : "";
        return new LostItemDto(
            String.valueOf(r.getId()), 
            r.getWorkspaceId(), 
            r.getDescription(), 
            at,
            r.getCategory() != null ? r.getCategory() : "GENERAL",
            r.getStatus() != null ? r.getStatus() : "REPORTED"
        );
    }
}
