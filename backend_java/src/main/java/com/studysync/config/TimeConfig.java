/* FILE PURPOSE: Uygulama konfigurasyonu (CORS, security, zaman vb.) ve runtime davranisi ayarlari. */

package com.studysync.config;

import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Testte sabit saat için {@link Clock} bean’i değiştirilebilir. */
@Configuration
public class TimeConfig {

    @Bean
    public Clock clock() {
        return Clock.systemUTC();
    }
}
