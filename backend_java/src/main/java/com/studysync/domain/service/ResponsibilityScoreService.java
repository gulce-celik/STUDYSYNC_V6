/* FILE PURPOSE: Is kurallari ve use-case akislari; controller ve repository arasinda orkestrasyon. */

package com.studysync.domain.service;

import com.studysync.domain.entity.UserAccount;
import com.studysync.domain.repository.UserAccountRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Kullanıcı {@code responsibilityScore} (0–100) güncellemeleri — iptal, check-in, no-show.
 *
 * <p><b>Kullanım yerleri:</b> {@link com.studysync.domain.policy.CancellationScoringPolicy},
 * {@link com.studysync.domain.policy.QrCheckInPolicy} sonrası, rezervasyon oluşturma kota kontrolü.
 *
 * <p><b>İş kuralları:</b> skoru clamp(0,100); audit log (ileride).
 */
@Service
public class ResponsibilityScoreService {

    private final UserAccountRepository userAccountRepository;

    public ResponsibilityScoreService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    @Transactional
    public void applyDelta(long userId, int delta) {
        final UserAccount u =
                userAccountRepository.findById(userId).orElseThrow(() -> new IllegalStateException("user not found"));
        int next = (u.getResponsibilityScore() == null ? 100 : u.getResponsibilityScore()) + delta;
        next = Math.max(0, Math.min(100, next));
        u.setResponsibilityScore(next);
        userAccountRepository.save(u);
    }
}
