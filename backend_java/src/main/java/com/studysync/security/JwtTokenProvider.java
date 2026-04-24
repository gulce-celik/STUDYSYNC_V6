package com.studysync.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtTokenProvider {
    // Antigravity Modification: Full implementation of the JJWT provider logic for secure token lifecycle management.

    private final SecretKey jwtSecret;
    private final long jwtExpirationMs;

    public JwtTokenProvider(
            @Value("${app.jwtSecret:ThisIsAVeryLongSecretForTestingPurposesStudySync123!}") String secret,
            @Value("${app.jwtExpirationMs:86400000}") long expirationMs) {
        this.jwtSecret = Keys.hmacShaKeyFor(secret.getBytes());
        this.jwtExpirationMs = expirationMs;
    }

    public String createAccessTokenForUserId(long userId) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationMs);

        return Jwts.builder()
                .subject(Long.toString(userId))
                .issuedAt(new Date())
                .expiration(expiryDate)
                .signWith(jwtSecret)
                .compact();
    }

    public String createRefreshTokenValue() {
        return UUID.randomUUID().toString();
    }

    public long parseUserIdFromAccessToken(String bearerToken) {
        Claims claims = Jwts.parser()
                .verifyWith(jwtSecret)
                .build()
                .parseSignedClaims(bearerToken)
                .getPayload();

        return Long.parseLong(claims.getSubject());
    }
}
