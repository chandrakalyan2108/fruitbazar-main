package com.fruitbazar.data;

import com.fruitbazar.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * User lookup. When the database is configured (DB_HOST set - always the case
 * on AWS), users are read from the MySQL "users" table and passwords are
 * verified against PBKDF2 hashes. Otherwise it falls back to the original
 * in-memory demo store for local development.
 *
 * Demo login: username "demo", password "demo123"
 */
public class UserStore {

    private static final Logger LOG = Logger.getLogger(UserStore.class.getName());
    private static final Map<String, User> USERS = new HashMap<>();

    static {
        USERS.put("demo", new User("demo", "demo123", "Demo Customer", "demo@example.com"));
    }

    private UserStore() {
    }

    public static User authenticate(String username, String password) {
        if (username == null || password == null) {
            return null;
        }
        if (Database.isEnabled()) {
            return authenticateFromDatabase(username, password);
        }
        User user = USERS.get(username);
        if (user != null && user.getPassword().equals(password)) {
            return user;
        }
        return null;
    }

    private static User authenticateFromDatabase(String username, String password) {
        String sql = "SELECT username, password_hash, full_name, email FROM users WHERE username = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && PasswordHasher.verify(password, rs.getString("password_hash"))) {
                    // Never keep the password hash in the HTTP session.
                    return new User(rs.getString("username"), null,
                            rs.getString("full_name"), rs.getString("email"));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "Login lookup failed", e);
        }
        return null;
    }
}
