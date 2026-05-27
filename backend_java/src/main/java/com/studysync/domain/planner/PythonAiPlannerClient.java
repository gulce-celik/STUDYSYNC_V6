/* FILE PURPOSE: Python AI microservice HTTP istemcisi. */

package com.studysync.domain.planner;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.studysync.domain.dto.AiPlannerContextDto;
import com.studysync.domain.dto.AiSuggestionsResponseDto;
import com.studysync.domain.dto.GuidedChatContextDto;
import com.studysync.domain.dto.GuidedChatResponseDto;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class PythonAiPlannerClient {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .version(HttpClient.Version.HTTP_1_1)
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    @Value("${app.ai.python.base-url:http://localhost:8090}")
    private String baseUrl;

    @Value("${app.ai.python.enabled:true}")
    private boolean enabled;

    public boolean isEnabled() {
        return enabled;
    }

    public Optional<AiSuggestionsResponseDto> fetchSuggestions(AiPlannerContextDto context) {
        if (!enabled) {
            return Optional.empty();
        }
        try {
            String body = objectMapper.writeValueAsString(context);
            String url = baseUrl.replaceAll("/$", "") + "/planner/suggestions";
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(50))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 400) {
                System.err.println("Python AI service error (" + response.statusCode() + "): " + response.body());
                return Optional.empty();
            }
            return Optional.of(objectMapper.readValue(response.body(), AiSuggestionsResponseDto.class));
        } catch (Exception ex) {
            System.err.println("Python AI service call failed: " + ex.getMessage());
            return Optional.empty();
        }
    }

    public Optional<GuidedChatResponseDto> fetchGuidedChat(GuidedChatContextDto context) {
        if (!enabled) {
            return Optional.empty();
        }
        try {
            String body = objectMapper.writeValueAsString(context);
            String url = baseUrl.replaceAll("/$", "") + "/planner/guided-chat";
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(40))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 400) {
                System.err.println("Python guided-chat error (" + response.statusCode() + "): " + response.body());
                return Optional.empty();
            }
            return Optional.of(objectMapper.readValue(response.body(), GuidedChatResponseDto.class));
        } catch (Exception ex) {
            System.err.println("Python guided-chat call failed: " + ex.getMessage());
            return Optional.empty();
        }
    }
}
