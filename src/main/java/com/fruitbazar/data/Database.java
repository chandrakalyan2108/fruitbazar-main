package com.fruitbazar.data;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Central access point for the MySQL (Amazon RDS) connection pool.
 *
 * Configuration comes from environment variables, which ECS injects at
 * container start (DB_USER / DB_PASSWORD come from AWS Secrets Manager):
 *
 *   DB_HOST, DB_PORT (default 3306), DB_NAME (default fruitbazar),
 *   DB_USER, DB_PASSWORD
 *
 * If DB_HOST is not set (e.g. a quick local run of the WAR), the app falls
 * back to its original in-memory behaviour so local development still works.
 */
public final class Database {

    private static volatile HikariDataSource dataSource;

    private Database() {
    }

    public static boolean isEnabled() {
        String host = System.getenv("DB_HOST");
        return host != null && !host.isBlank();
    }

    public static Connection getConnection() throws SQLException {
        if (!isEnabled()) {
            throw new SQLException("Database is not configured (DB_HOST is not set)");
        }
        return pool().getConnection();
    }

    private static HikariDataSource pool() {
        HikariDataSource ds = dataSource;
        if (ds == null) {
            synchronized (Database.class) {
                ds = dataSource;
                if (ds == null) {
                    ds = createPool();
                    dataSource = ds;
                }
            }
        }
        return ds;
    }

    private static HikariDataSource createPool() {
        String host = System.getenv("DB_HOST");
        String port = envOrDefault("DB_PORT", "3306");
        String name = envOrDefault("DB_NAME", "fruitbazar");

        HikariConfig cfg = new HikariConfig();
        cfg.setPoolName("fruitbazar-db");
        cfg.setDriverClassName("com.mysql.cj.jdbc.Driver");
        // sslMode=REQUIRED: traffic to RDS is always encrypted
        // (the RDS parameter group also enforces require_secure_transport).
        cfg.setJdbcUrl("jdbc:mysql://" + host + ":" + port + "/" + name
                + "?sslMode=REQUIRED&serverTimezone=UTC&characterEncoding=UTF-8");
        cfg.setUsername(System.getenv("DB_USER"));
        cfg.setPassword(System.getenv("DB_PASSWORD"));
        cfg.setMaximumPoolSize(Integer.parseInt(envOrDefault("DB_POOL_SIZE", "10")));
        cfg.setMinimumIdle(1);
        cfg.setConnectionTimeout(10_000);
        cfg.setValidationTimeout(5_000);
        cfg.setMaxLifetime(600_000);
        // Don't fail Tomcat startup if RDS is briefly unreachable; connections
        // are retried lazily on first use.
        cfg.setInitializationFailTimeout(-1);
        return new HikariDataSource(cfg);
    }

    public static synchronized void shutdown() {
        if (dataSource != null) {
            dataSource.close();
            dataSource = null;
        }
    }

    private static String envOrDefault(String key, String def) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? def : v;
    }
}
