/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.WeeklyScheduleBlockDto;
import com.studysync.domain.dto.WeeklyScheduleResponseDto;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;

/**
 * Kullanıcı haftalık meşgul saatleri (ders/kulüp/kişisel).
 *
 * <p><b>getWeekly()</b>: Oturumdaki öğrencinin bloklarını DB’den okuyun.
 *
 * <p><b>putWeekly(blocks)</b>: Tam liste replace veya diff — mobil istemci tüm ızgarayı gönderiyorsa replace uygun.
 * Gün/slot/type doğrulaması (izin verilen enum’lar).
 */
@Service
public class ScheduleService {
    private final List<WeeklyScheduleBlockDto> blocks = new ArrayList<>();

    public WeeklyScheduleResponseDto getWeekly() {
        // TODO: userId ile yükle; şimdilik bellekte tutulan (çoğunlukla boş) liste.
        return new WeeklyScheduleResponseDto(List.copyOf(blocks));
    }

    public ActionResultDto putWeekly(List<WeeklyScheduleBlockDto> next) {
        // TODO: Transaction + kullanıcıya göre kayıt.
        blocks.clear();
        if (next != null) {
            blocks.addAll(next);
        }
        return new ActionResultDto(true, "Stub: weekly schedule stored in memory only", null, null);
    }
}
