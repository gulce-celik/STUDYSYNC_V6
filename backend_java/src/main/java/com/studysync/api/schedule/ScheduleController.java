/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.schedule;

import com.studysync.domain.dto.ActionResultDto;
import com.studysync.domain.dto.WeeklySchedulePutRequestDto;
import com.studysync.domain.dto.WeeklyScheduleResponseDto;
import com.studysync.domain.service.ScheduleService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * GET/PUT /api/v1/schedule/weekly
 *
 * <p>PUT gövdesi: {@code WeeklySchedulePutRequestDto} — kullanıcıya göre yetkilendirme ekleyin
 * (başkasının programını yazamasın).
 */
@RestController
@RequestMapping("/api/v1/schedule")
public class ScheduleController {
    private final ScheduleService scheduleService;

    public ScheduleController(ScheduleService scheduleService) {
        this.scheduleService = scheduleService;
    }

    @GetMapping("/weekly")
    public WeeklyScheduleResponseDto getWeekly() {
        return scheduleService.getWeekly();
    }

    @PutMapping("/weekly")
    public ActionResultDto putWeekly(@RequestBody WeeklySchedulePutRequestDto body) {
        return scheduleService.putWeekly(body.blocks() != null ? body.blocks() : List.of());
    }
}
