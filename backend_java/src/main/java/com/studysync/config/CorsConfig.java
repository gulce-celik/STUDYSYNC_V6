/* FILE PURPOSE: Uygulama konfigurasyonu (CORS, security, zaman vb.) ve runtime davranisi ayarlari. */

package com.studysync.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * CORS — geliştirme için {@code *} kabul edilebilir; üretimde Flutter web / admin panel origin’lerini
 * whitelist edin ve {@code allowCredentials(true)} ile çakışmayı kontrol edin.
 */
@Configuration
public class CorsConfig {
    @Bean
    WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins("*")
                        .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS");
            }
        };
    }
}
