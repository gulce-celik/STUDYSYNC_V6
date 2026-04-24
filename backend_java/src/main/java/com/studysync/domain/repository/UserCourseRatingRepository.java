/* FILE PURPOSE: Spring Data repository; entity sorgulari/persist islemleri icin veri erisim katmani. */

package com.studysync.domain.repository;

import com.studysync.domain.entity.UserCourseRatingEntity;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Kullanıcı–ders oyları — rating gönderme ve tekil kayıt güncelleme.
 */
public interface UserCourseRatingRepository extends JpaRepository<UserCourseRatingEntity, Long> {

    Optional<UserCourseRatingEntity> findByUser_IdAndCourseCode(Long userId, String courseCode);
}
