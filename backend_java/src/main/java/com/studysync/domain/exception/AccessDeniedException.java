package com.studysync.domain.exception;

import org.springframework.http.HttpStatus;

public class AccessDeniedException extends StudySyncException {
    public AccessDeniedException(String message) {
        super(message, HttpStatus.FORBIDDEN);
    }
}
