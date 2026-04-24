/* FILE PURPOSE: HTTP endpoint katmani; request/response sozlesmesini servis katmanina baglar. */

package com.studysync.api.common;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * API hata gövdeleri — Flutter’ın parse edebileceği tutarlı JSON (ör. {@code message}, {@code fieldErrors}).
 *
 * <p><b>Genişletme:</b> {@code BusinessException}, {@code NotFoundException}, JWT süresi dolmuş.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> validation(MethodArgumentNotValidException ex) {
        final var errors =
                ex.getBindingResult().getFieldErrors().stream()
                        .map(fe -> Map.of("field", fe.getField(), "message", fe.getDefaultMessage()))
                        .toList();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", "Validation failed", "fieldErrors", errors));
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<Map<String, String>> conflict(IllegalStateException ex) {
        if (ex.getMessage() != null && ex.getMessage().contains("already registered")) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message", ex.getMessage()));
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", ex.getMessage()));
    }
}
