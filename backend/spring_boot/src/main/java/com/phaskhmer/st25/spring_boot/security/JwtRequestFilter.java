package com.phaskhmer.st25.spring_boot.security;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.ArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(JwtRequestFilter.class);

    @Value("${app.jwt.secret}")
    private String secret;

    private static final String USER_ID_CLAIM = "user_id";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        String jwtToken = null;
        String principalId = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwtToken = authorizationHeader.substring(7);
            logger.debug("Found Bearer token: {}", jwtToken);

            try {
                Key key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));

                Claims claims = Jwts.parserBuilder()
                        .setSigningKey(key)
                        .build()
                        .parseClaimsJws(jwtToken)
                        .getBody();

                principalId = claims.get(USER_ID_CLAIM, String.class);

                if (principalId != null) {
                    logger.info("JWT validated successfully. Principal ID: {}", principalId);
                } else {
                    logger.warn("JWT is valid but missing the required claim: {}", USER_ID_CLAIM);
                }

            } catch (io.jsonwebtoken.SignatureException e) {
                logger.error("JWT Signature validation failed (Secret Key Mismatch): {}", e.getMessage());
            } catch (io.jsonwebtoken.ExpiredJwtException e) {
                logger.warn("JWT is expired: {}", e.getMessage());
            } catch (Exception e) {
                logger.error("General JWT validation failed: {}", e.getMessage());
            }
        } else {
            logger.debug("No Authorization header or not a Bearer token found.");
        }

        // 5. Set Authentication Context if Principal ID is found and context is empty
        if (principalId != null && SecurityContextHolder.getContext().getAuthentication() == null) {

            // NOTE: We trust the token from Django. We use the principalId (user ID) 
            // as the username/principal for Spring Security context.
            // Create a dummy UserDetails object (no password or special roles needed for resource server)
            UserDetails userDetails = new User(principalId, "", new ArrayList<>());

            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities());

            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            // Set the authentication in the context
            SecurityContextHolder.getContext().setAuthentication(authToken);
            logger.debug("Security Context set for user ID: {}", principalId);
        }

        chain.doFilter(request, response);
    }
}
