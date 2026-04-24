package com.studysync.domain.exception;

import org.springframework.http.HttpStatus;

public class InvalidCredentialsException extends StudySyncException {
    public InvalidCredentialsException() {
        super("Invalid email or password.", HttpStatus.UNAUTHORIZED);
    }
}
