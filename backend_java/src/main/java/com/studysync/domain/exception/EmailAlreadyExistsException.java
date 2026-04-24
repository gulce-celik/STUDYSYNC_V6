package com.studysync.domain.exception;

import org.springframework.http.HttpStatus;

public class EmailAlreadyExistsException extends StudySyncException {
    public EmailAlreadyExistsException(String email) {
        super("Email '" + email + "' is already registered.", HttpStatus.CONFLICT);
    }
}
