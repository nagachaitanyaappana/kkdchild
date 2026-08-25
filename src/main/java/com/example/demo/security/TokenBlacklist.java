package com.example.demo.security;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class TokenBlacklist {

    private final Map<String, Long> revokedTokens = new ConcurrentHashMap<>();
    private final Map<String, Long> activeTokens = new ConcurrentHashMap<>();

    public void revoke(String token, long expirationTime) {
        revokedTokens.put(token, expirationTime);
        activeTokens.remove(token);
    }

    public boolean isRevoked(String token) {
        Long expiry = revokedTokens.get(token);
        if (expiry == null) {
            return false;
        }
        if (System.currentTimeMillis() > expiry) {
            revokedTokens.remove(token);
            return false;
        }
        return true;
    }

    public void activate(String token, long expirationTime) {
        activeTokens.put(token, expirationTime);
    }

    public boolean isActive(String token) {
        Long expiry = activeTokens.get(token);
        if (expiry == null) {
            return false;
        }
        if (System.currentTimeMillis() > expiry) {
            activeTokens.remove(token);
            return false;
        }
        return true;
    }

    @Scheduled(fixedRate = 60000)
    public void cleanupExpiredTokens() {
        long now = System.currentTimeMillis();
        revokedTokens.entrySet().removeIf(entry -> now > entry.getValue());
        activeTokens.entrySet().removeIf(entry -> now > entry.getValue());
    }
}
