/* FILE PURPOSE: JPA entity; veritabani tablosu alani ve iliski modelini tanimlar. */

package com.studysync.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;

/**
 * Uzun ömürlü oturum yenileme — {@code POST /auth/refresh} (sözleşmeye eklenecek) ile kullanılacak.
 *
 * <p><b>Güvenlik:</b> token’ın kendisini değil hash’ini saklayın; rotation (her refresh’te eskiyi geçersiz kılma).
 *
 * <p><b>Flutter:</b> şu an yalnızca accessToken kullanılıyor; refresh endpoint eklendiğinde mobil taraf güncellenir.
 */
@Entity
@Table(name = "refresh_tokens")
public class RefreshTokenEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 128)
    private String tokenHash;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id")
    private UserAccount user;

    @Column(nullable = false)
    private Instant expiresAt;

    protected RefreshTokenEntity() {}

    public Long getId() {
        return id;
    }

    public String getTokenHash() {
        return tokenHash;
    }

    public void setTokenHash(String tokenHash) {
        this.tokenHash = tokenHash;
    }

    public UserAccount getUser() {
        return user;
    }

    public void setUser(UserAccount user) {
        this.user = user;
    }

    public Instant getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Instant expiresAt) {
        this.expiresAt = expiresAt;
    }
}
