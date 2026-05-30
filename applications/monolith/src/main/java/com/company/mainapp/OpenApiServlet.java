package com.company.mainapp;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "openApiServlet", urlPatterns = "/api/openapi.json")
public class OpenApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String schema = """
            {
              "openapi": "3.0.3",
              "info": {
                "title": "Monolith API",
                "version": "1.0.0",
                "description": "Tomcat monolith endpoints"
              },
              "servers": [
                { "url": "/monolith" }
              ],
              "paths": {
                "/health": {
                  "get": {
                    "summary": "Health check",
                    "responses": {
                      "200": { "description": "OK" }
                    }
                  }
                },
                "/api/customer/{id}": {
                  "get": {
                    "summary": "Get customer by id",
                    "parameters": [
                      {
                        "name": "id",
                        "in": "path",
                        "required": true,
                        "schema": { "type": "integer" }
                      }
                    ],
                    "responses": {
                      "200": { "description": "Customer" },
                      "404": { "description": "Not found" }
                    }
                  }
                },
                "/api/customer-summary/{id}": {
                  "get": {
                    "summary": "Get customer with orders",
                    "parameters": [
                      {
                        "name": "id",
                        "in": "path",
                        "required": true,
                        "schema": { "type": "integer" }
                      }
                    ],
                    "responses": {
                      "200": { "description": "Summary" }
                    }
                  }
                },
                "/api/microservice-status": {
                  "get": {
                    "summary": "Bridge endpoint to microservice status",
                    "responses": {
                      "200": { "description": "Microservice status" }
                    }
                  }
                }
              }
            }
            """;

        resp.getWriter().write(schema);
    }
}