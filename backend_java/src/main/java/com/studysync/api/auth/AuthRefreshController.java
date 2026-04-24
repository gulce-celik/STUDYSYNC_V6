/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.auth;

import com.studysync.domain.dto.LoginResponseDto;
import com.studysync.domain.dto.RefreshTokenRequestDto;
import com.studysync.domain.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

/**
 * {@code POST /api/v1/auth/refresh} — access token yenileme (sözleşme dokümanına eklenecek).
 *
 * <p>İstemci: mobil şu an yalnızca login sonrası access kullanıyor; bu uç tamamlanınca Flutter tarafına
 * token yenileme interceptor’ı eklenir.
 */
@RestController
@RequestMapping("/api/v1/auth")
public class AuthRefreshController {

    private final AuthService authService;

    public AuthRefreshController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/refresh")
    public LoginResponseDto refresh(@Valid @RequestBody RefreshTokenRequestDto body) {
        try {
            return authService.refresh(body.refreshToken());
        } catch (UnsupportedOperationException e) {
            throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED, e.getMessage());
        }
    }
}
