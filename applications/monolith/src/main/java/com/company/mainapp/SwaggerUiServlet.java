package com.company.mainapp;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "swaggerUiServlet", urlPatterns = "/swagger")
public class SwaggerUiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        resp.setCharacterEncoding("UTF-8");
        String html = """
            <!doctype html>
            <html lang=\"en\">
              <head>
                <meta charset=\"UTF-8\" />
                <meta name=\"viewport\" content=\"width=device-width,initial-scale=1\" />
                <title>Monolith Swagger</title>
                <link rel=\"stylesheet\" href=\"https://unpkg.com/swagger-ui-dist@5/swagger-ui.css\" />
              </head>
              <body>
                <div id=\"swagger-ui\"></div>
                <script src=\"https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js\"></script>
                <script>
                  window.ui = SwaggerUIBundle({
                    url: '/monolith/api/openapi.json',
                    dom_id: '#swagger-ui'
                  });
                </script>
              </body>
            </html>
            """;
        resp.getWriter().write(html);
    }
}