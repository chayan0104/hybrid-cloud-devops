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

@WebServlet(name = "microserviceBridgeServlet", urlPatterns = "/api/microservice-status")
public class MicroserviceBridgeServlet extends HttpServlet {
    private final HttpClient client = HttpClient.newHttpClient();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String baseUrl = System.getenv().getOrDefault("MICROSERVICE_URL", "http://localhost:8081");

        try {
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + "/api/status"))
                .GET()
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            resp.setStatus(response.statusCode());
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(response.body());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ServletException("Microservice call interrupted", e);
        }
    }
}