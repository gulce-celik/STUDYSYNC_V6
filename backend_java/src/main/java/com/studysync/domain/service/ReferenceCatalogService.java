/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.dto.DepartmentOptionDto;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

/**
 * Sabit / veritabanı katalogları — bölüm listesi, ileride ders bölüm eşlemesi.
 *
 * <p><b>Flutter uyumu:</b> {@code RegistrationMockData.departments} ile aynı {@code id} değerleri (cse, ie, math).
 *
 * <p><b>Geliştirme:</b> şimdilik bellek içi liste; prod’da {@code department} tablosu + cache.
 */
@Service
public class ReferenceCatalogService {

    private static final List<DepartmentOptionDto> DEPARTMENTS =
            List.of(
                    new DepartmentOptionDto("cse", "Computer Engineering"),
                    new DepartmentOptionDto("ie", "Industrial Engineering"),
                    new DepartmentOptionDto("math", "Mathematics"));

    public List<DepartmentOptionDto> listDepartments() {
        return List.copyOf(DEPARTMENTS);
    }

    /** {@link com.studysync.domain.entity.UserAccount#getDepartmentId()} → görünen isim. */
    public Optional<String> resolveDepartmentName(String departmentId) {
        if (departmentId == null) {
            return Optional.empty();
        }
        return DEPARTMENTS.stream()
                .filter(d -> d.id().equalsIgnoreCase(departmentId))
                .map(DepartmentOptionDto::name)
                .findFirst();
    }
}
