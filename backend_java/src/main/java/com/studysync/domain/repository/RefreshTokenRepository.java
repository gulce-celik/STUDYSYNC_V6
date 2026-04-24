/* FILE PURPOSE: Spring Data repository; entity sorgulari/persist islemleri icin veri erisim katmani. */

package com.studysync.domain.repository;

import com.studysync.domain.entity.RefreshTokenEntity;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Refresh token satırları — oturum yenileme ve revoke.
 */
public interface RefreshTokenRepository extends JpaRepository<RefreshTokenEntity, Long> {

    Optional<RefreshTokenEntity> findByTokenHash(String tokenHash);

    void deleteByUser_Id(Long userId);
}
