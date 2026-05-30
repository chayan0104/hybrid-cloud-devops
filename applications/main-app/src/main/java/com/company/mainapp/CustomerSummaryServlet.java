package com.company.mainapp;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "customerSummaryServlet", urlPatterns = "/api/customer-summary/*")
public class CustomerSummaryServlet extends HttpServlet {
    private final HttpClient client = HttpClient.newHttpClient();

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

        Customer customer = switch (customerId) {
            case 1 -> new Customer(1, "John Doe");
            case 2 -> new Customer(2, "Jane Smith");
            default -> null;
        };

        if (customer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"error\":\"Customer not found\"}");
            return;
        }

        String baseUrl = System.getenv().getOrDefault("MICROSERVICE_URL", "http://localhost:8081");
        String ordersJson = "[]";
        try {
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + "/api/orders/" + customerId))
                .GET()
                .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == HttpServletResponse.SC_OK) {
                ordersJson = response.body();
            }
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
            throw new ServletException("Interrupted while calling microservice", ex);
        }

        String payload = "{" +
            "\"customer\":{" +
            "\"id\":" + customer.id() + "," +
            "\"name\":\"" + customer.name() + "\"}," +
            "\"orders\":" + ordersJson +
            "}";

        resp.getWriter().write(payload);
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