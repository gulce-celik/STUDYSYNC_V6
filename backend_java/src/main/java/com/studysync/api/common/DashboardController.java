/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.common;

import com.studysync.domain.dto.HomeDashboardResponseDto;
import com.studysync.domain.service.DashboardService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * GET /api/v1/dashboard/home
 *
 * <p>Mantık: {@link com.studysync.domain.service.DashboardService#homeForCurrentUser()}.
 */
@RestController
@RequestMapping("/api/v1/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/home")
    public HomeDashboardResponseDto home() {
        return dashboardService.homeForCurrentUser();
    }
}
