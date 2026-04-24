/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.common;

import com.studysync.domain.dto.DepartmentOptionDto;
import com.studysync.domain.service.ReferenceCatalogService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Mobil kayıt ve onboarding ile hizalı katalog uçları.
 *
 * <p>{@code GET /reference/departments} — Flutter {@code RegistrationMockData.departments} ile aynı kimlikler;
 * veri {@link ReferenceCatalogService} üzerinden gelir (ileride repository).
 */
@RestController
@RequestMapping("/api/v1/reference")
public class ReferenceController {

    private final ReferenceCatalogService referenceCatalogService;

    public ReferenceController(ReferenceCatalogService referenceCatalogService) {
        this.referenceCatalogService = referenceCatalogService;
    }

    @GetMapping("/departments")
    public List<DepartmentOptionDto> departments() {
        return referenceCatalogService.listDepartments();
    }
}
