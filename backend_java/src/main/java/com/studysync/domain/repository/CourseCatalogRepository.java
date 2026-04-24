/* FILE PURPOSE: Spring Data repository; entity sorgulari/persist islemleri icin veri erisim katmani. */

package com.studysync.domain.repository;

import com.studysync.domain.entity.CourseCatalogEntity;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Ders kataloğu — Course Rating listesi.
 */
public interface CourseCatalogRepository extends JpaRepository<CourseCatalogEntity, String> {}
