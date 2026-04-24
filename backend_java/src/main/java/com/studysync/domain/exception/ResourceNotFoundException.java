package com.studysync.domain.exception;

import org.springframework.http.HttpStatus;

public class ResourceNotFoundException extends StudySyncException {
    public ResourceNotFoundException(String resource, String id) {
        super(resource + " with ID '" + id + "' not found.", HttpStatus.NOT_FOUND);
    }
}
