package com.example.hello;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class HelloController {

    @Value("${app.greeting:Hello}")
    private String greeting;

    @Value("${app.name:World}")
    private String name;

    @GetMapping("/")
    public Map<String, String> hello() {
        return Map.of("message", greeting + ", " + name + "!");
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }
}
