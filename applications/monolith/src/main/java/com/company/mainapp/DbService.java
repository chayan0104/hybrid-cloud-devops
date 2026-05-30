package com.company.mainapp;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DbService {
    private final String jdbcUrl;
    private final String user;
    private final String password;

    public DbService() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String host = System.getenv().getOrDefault("DB_HOST", "localhost");
        String port = System.getenv().getOrDefault("DB_PORT", "5432");
        String db = System.getenv().getOrDefault("DB_NAME", "app_db");
        this.user = System.getenv().getOrDefault("DB_USER", "app_user");
        this.password = System.getenv().getOrDefault("DB_PASSWORD", "app_password");
        this.jdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + db;
    }

    public Customer findCustomerById(int id) throws SQLException {
        String sql = "SELECT id, name FROM customers WHERE id = ?";
        try (Connection connection = DriverManager.getConnection(jdbcUrl, user, password);
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return new Customer(rs.getInt("id"), rs.getString("name"));
                }
                return null;
            }
        }
    }

    public int countOrdersByCustomer(int customerId) throws SQLException {
        String sql = "SELECT COUNT(*) AS total FROM orders WHERE customer_id = ?";
        try (Connection connection = DriverManager.getConnection(jdbcUrl, user, password);
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
                return 0;
            }
        }
    }
}