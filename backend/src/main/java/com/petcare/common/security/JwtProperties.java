package com.petcare.common.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Propriétés de configuration JWT (préfixe {@code petcare.security.jwt}).
 */
@ConfigurationProperties(prefix = "petcare.security.jwt")
public record JwtProperties(
        String secret,
        long accessTokenExpirationMs,
        long refreshTokenExpirationMs
) {
}
