package com.company.microservice.controller;

import java.time.Instant;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api")
public class StatusController {

    @Value("${app.environment:local}")
    private String environment;

    @GetMapping("/status")
    public Map<String, Object> status() {
        return Map.of(
            "status", "UP",
            "service", "microservice",
            "environment", environment,
            "timestamp", Instant.now().toString()
        );
    }
}