package com.company.mainapp;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "customerServlet", urlPatterns = "/api/customer/*")
public class CustomerServlet extends HttpServlet {
    private static final Map<Integer, Customer> CUSTOMERS = new HashMap<>();

    static {
        CUSTOMERS.put(1, new Customer(1, "John Doe"));
        CUSTOMERS.put(2, new Customer(2, "Jane Smith"));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Integer customerId = extractId(req.getPathInfo());
        if (customerId == null || !CUSTOMERS.containsKey(customerId)) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"error\":\"Customer not found\"}");
            return;
        }

        Customer customer = CUSTOMERS.get(customerId);
        resp.getWriter().write("{\"id\":" + customer.id() + ",\"name\":\"" + customer.name() + "\"}");
    }

    private Integer extractId(String pathInfo) {
        if (pathInfo == null || pathInfo.length() < 2) {
            return null;
        }
        try {
            return Integer.parseInt(pathInfo.substring(1));
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}