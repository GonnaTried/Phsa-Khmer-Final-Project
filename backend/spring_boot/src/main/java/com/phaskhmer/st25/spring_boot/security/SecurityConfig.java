package com.phaskhmer.st25.spring_boot.security;

import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod; // <-- Import Customizer
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource; // <-- Ensure this is imported for Arrays.asList

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtRequestFilter jwtRequestFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. ENABLE CORS
                .cors(Customizer.withDefaults()) // This tells Spring Security to use the corsConfigurationSource Bean

                // 2. Disable CSRF (using the lambda style for modern Spring Boot)
                .csrf(csrf -> csrf.disable())
                // 3. Session Management
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 4. Authorization Rules
                .authorizeHttpRequests(auth -> auth
                        // CRITICAL FIX: Allow OPTIONS preflight requests to bypass security
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers(
                                "/payment-success",
                                "/payment-return",
                                "/payment-cancel",
                                "/api/payment/status",
                                "/stripe-webhook/**"
                        ).permitAll()
                        // Allow static content and homepage
                        .requestMatchers("/static/**", "/templates/**", "/").permitAll()
                        // Specific public GET endpoint example
                        .requestMatchers(HttpMethod.GET, "/api/products/**").permitAll()
                        .requestMatchers("/api/seller/**").authenticated()
                        .requestMatchers("/api/public/**").permitAll()
                        .requestMatchers("/api/cart/**").authenticated()
                        .requestMatchers("/api/payments/**").authenticated()
                        .requestMatchers(HttpMethod.GET, "/api/payment/status").permitAll()
                        .requestMatchers("/api/checkout/**").authenticated()
                        .requestMatchers("/api/**").authenticated()
                        // Default catch-all rule (already covered by /api/** but kept for completeness)
                        .anyRequest().authenticated()
                )
                // 5. JWT Filter
                .addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // CORS Configuration Source (This defines *what* is allowed)
    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        // Ensure you include 127.0.0.1:8080 or the IP address if you use that
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:5000", "http://127.0.0.1:5000", "https://exercise-deborah-roommates-demand.trycloudflare.com"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
