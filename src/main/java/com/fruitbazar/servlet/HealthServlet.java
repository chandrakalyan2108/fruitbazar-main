package com.fruitbazar.servlet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Liveness endpoint used by the ALB target group health check.
 * Deliberately does NOT touch the database, so a brief RDS blip
 * doesn't cause the load balancer to kill every task at once.
 */
@WebServlet("/health")
public class HealthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/plain");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write("OK");
    }
}
