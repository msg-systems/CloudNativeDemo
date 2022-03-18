package de.msg.cn.app.adapter.rest;

import com.fasterxml.jackson.core.JsonProcessingException;
import de.msg.cn.app.api.model.Error;
import de.msg.cn.app.api.model.ErrorCode;
import de.msg.cn.app.domain.DivideByZeroException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@RestControllerAdvice
public class RestExceptionHandler extends ResponseEntityExceptionHandler {

    @Override
    protected ResponseEntity<Object> handleExceptionInternal(Exception ex, Object body,
                                                             HttpHeaders headers, HttpStatusCode status,
                                                             WebRequest request) {

        if (ex instanceof HttpMessageNotReadableException || ex instanceof JsonProcessingException) {
            return new ResponseEntity<>(
                    new Error().code(ErrorCode.INVALID_FORMAT).message("Json format or values are invalid."),
                    HttpStatus.BAD_REQUEST
            );
        }

        logger.error("Uncaught Exception: ", ex);
        return new ResponseEntity<>(
                new Error().code(ErrorCode.INTERNAL_ERROR).message("An internal error has occurred."),
                HttpStatus.INTERNAL_SERVER_ERROR
        );
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Error> handleExceptions(RuntimeException ex, WebRequest webRequest) {
        logger.error("Uncaught RuntimeException: ", ex);
        return new ResponseEntity<>(
                new Error().code(ErrorCode.INTERNAL_ERROR).message("An internal error has occurred."),
                HttpStatus.INTERNAL_SERVER_ERROR
        );
    }

    @ExceptionHandler(HttpStatusCodeException.class)
    public ResponseEntity<Error> handleHttpStatusCodeExceptions(HttpStatusCodeException ex) {
        return new ResponseEntity<>(new Error().code(ErrorCode.INTERNAL_ERROR).message(ex.getMessage()), ex.getStatusCode());
    }

    @ExceptionHandler(DivideByZeroException.class)
    public ResponseEntity<Error> handleDivideByZero(DivideByZeroException ex) {
        return new ResponseEntity<>(new Error().code(ErrorCode.DIVISION_BY_ZERO).message(ex.getMessage()), HttpStatus.BAD_REQUEST);
    }
}
