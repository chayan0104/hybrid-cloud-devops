package com.company.microservice.service;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.company.microservice.entity.Order;

@Service
public class OrderService {
    private final JdbcTemplate jdbcTemplate;

    public OrderService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<Order> findByCustomerId(int customerId) {
        return jdbcTemplate.query(
            "SELECT id, customer_id, product_name AS product, quantity FROM orders WHERE customer_id = ? ORDER BY id",
            (rs, rowNum) -> new Order(
                rs.getInt("id"),
                rs.getInt("customer_id"),
                rs.getString("product"),
                rs.getInt("quantity")
            ),
            customerId
        );
    }
}