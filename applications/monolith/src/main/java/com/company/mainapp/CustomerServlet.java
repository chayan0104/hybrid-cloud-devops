package com.company.mainapp;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "customerServlet", urlPatterns = "/api/customer/*")
public class CustomerServlet extends HttpServlet {
    private final DbService dbService = new DbService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        Integer customerId = extractId(req.getPathInfo());
        if (customerId == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid customer id\"}");
            return;
        }

        Customer customer;
        try {
            customer = dbService.findCustomerById(customerId);
        } catch (SQLException ex) {
            throw new ServletException("Database query failed", ex);
        }

        if (customer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"error\":\"Customer not found\"}");
            return;
        }

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