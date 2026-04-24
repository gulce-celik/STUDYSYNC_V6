package com.studysync.domain.exception;

import org.springframework.http.HttpStatus;

public class InvalidDomainException extends StudySyncException {
    public InvalidDomainException(String domain) {
        super("Only emails with domain '" + domain + "' are allowed.", HttpStatus.BAD_REQUEST);
    }
}
