/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.common;

import com.studysync.domain.dto.CheckInResultDto;
import com.studysync.domain.dto.CheckInVerifyRequestDto;
import com.studysync.domain.service.CheckInService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * POST /api/v1/checkin/verify
 *
 * <p>Mantık: {@link com.studysync.domain.service.CheckInService#verify(CheckInVerifyRequestDto)}.
 */
@RestController
@RequestMapping("/api/v1/checkin")
public class CheckInController {

    private final CheckInService checkInService;

    public CheckInController(CheckInService checkInService) {
        this.checkInService = checkInService;
    }

    @PostMapping("/verify")
    public CheckInResultDto verify(@Valid @RequestBody CheckInVerifyRequestDto request) {
        return checkInService.verify(request);
    }
}
