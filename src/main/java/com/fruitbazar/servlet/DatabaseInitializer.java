package com.fruitbazar.servlet;

import com.fruitbazar.data.Database;
import com.fruitbazar.data.PasswordHasher;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * On startup, creates the database schema (idempotent) and seeds the demo
 * user. Safe to run concurrently from several Fargate tasks.
 */
@WebListener
public class DatabaseInitializer implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(DatabaseInitializer.class.getName());

    private static final String[] SCHEMA = {
        "CREATE TABLE IF NOT EXISTS users ("
            + " id BIGINT AUTO_INCREMENT PRIMARY KEY,"
            + " username VARCHAR(64) NOT NULL UNIQUE,"
            + " password_hash VARCHAR(255) NOT NULL,"
            + " full_name VARCHAR(128),"
            + " email VARCHAR(255),"
            + " created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",

        "CREATE TABLE IF NOT EXISTS orders ("
            + " id VARCHAR(40) PRIMARY KEY,"
            + " username VARCHAR(64) NOT NULL,"
            + " customer_name VARCHAR(128),"
            + " address TEXT,"
            + " phone VARCHAR(32),"
            + " total DECIMAL(12,2) NOT NULL,"
            + " created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
            + " INDEX idx_orders_username (username)"
            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",

        "CREATE TABLE IF NOT EXISTS order_items ("
            + " id BIGINT AUTO_INCREMENT PRIMARY KEY,"
            + " order_id VARCHAR(40) NOT NULL,"
            + " fruit_id INT NOT NULL,"
            + " fruit_name VARCHAR(128) NOT NULL,"
            + " unit_price DECIMAL(10,2) NOT NULL,"
            + " quantity INT NOT NULL,"
            + " subtotal DECIMAL(12,2) NOT NULL,"
            + " CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE"
            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
    };

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        if (!Database.isEnabled()) {
            LOG.info("DB_HOST not set - running with in-memory user store (no persistence).");
            return;
        }
        for (int attempt = 1; attempt <= 10; attempt++) {
            try {
                initSchema();
                LOG.info("Database schema ready.");
                return;
            } catch (SQLException e) {
                LOG.log(Level.WARNING, "Database init attempt " + attempt + "/10 failed: " + e.getMessage());
                try {
                    Thread.sleep(3_000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
        }
        LOG.severe("Database schema could not be initialised; DB-backed features will fail until RDS is reachable.");
    }

    private void initSchema() throws SQLException {
        try (Connection con = Database.getConnection()) {
            try (Statement st = con.createStatement()) {
                for (String ddl : SCHEMA) {
                    st.execute(ddl);
                }
            }
            // Seed the demo account once (INSERT IGNORE keeps it idempotent).
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT IGNORE INTO users (username, password_hash, full_name, email) VALUES (?, ?, ?, ?)")) {
                ps.setString(1, "demo");
                ps.setString(2, PasswordHasher.hash("demo123"));
                ps.setString(3, "Demo Customer");
                ps.setString(4, "demo@example.com");
                ps.executeUpdate();
            }
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        Database.shutdown();
    }
}
