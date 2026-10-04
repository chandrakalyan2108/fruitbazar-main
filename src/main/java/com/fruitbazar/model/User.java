package com.fruitbazar.model;

import java.io.Serializable;

/**
 * Simple user record for demo authentication.
 * NOTE: This is an in-memory demo store with plain-text passwords for
 * simplicity. Replace with a real database + hashed passwords (e.g. BCrypt)
 * before using this in production.
 */
public class User implements Serializable {

    private final String username;
    private final String password;
    private final String fullName;
    private final String email;

    public User(String username, String password, String fullName, String email) {
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }
}
