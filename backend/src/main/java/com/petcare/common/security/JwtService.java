package com.petcare.common.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;

/**
 * Génère et valide les jetons JWT (access et refresh).
 * Signature HS256 avec la clé secrète de {@link JwtProperties}.
 */
@Service
public class JwtService {

    private final SecretKey key;
    private final JwtProperties properties;

    public JwtService(JwtProperties properties) {
        this.properties = properties;
        this.key = Keys.hmacShaKeyFor(properties.secret().getBytes(StandardCharsets.UTF_8));
    }

    /** Génère un access token court contenant l'identité et les rôles. */
    public String generateAccessToken(String userId, String email, List<String> roles) {
        return buildToken(userId, email, roles, properties.accessTokenExpirationMs());
    }

    /** Génère un refresh token long (identité uniquement). */
    public String generateRefreshToken(String userId, String email) {
        return buildToken(userId, email, List.of(), properties.refreshTokenExpirationMs());
    }

    private String buildToken(String userId, String email, List<String> roles, long expirationMs) {
        Date now = new Date();
        return Jwts.builder()
                .subject(userId)
                .claim("email", email)
                .claim("roles", roles)
                .issuedAt(now)
                .expiration(new Date(now.getTime() + expirationMs))
                .signWith(key)
                .compact();
    }

    /** Valide la signature et l'expiration, puis retourne les claims. Lève une exception si invalide. */
    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean isValid(String token) {
        try {
            parse(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @SuppressWarnings("unchecked")
    public List<String> extractRoles(Claims claims) {
        return (List<String>) claims.getOrDefault("roles", List.of());
    }
}
