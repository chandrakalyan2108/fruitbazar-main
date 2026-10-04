package com.fruitbazar.servlet;

import com.fruitbazar.data.Database;
import com.fruitbazar.data.OrderRepository;
import com.fruitbazar.model.CartItem;
import com.fruitbazar.model.User;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(CheckoutServlet.class.getName());

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart.jsp");
            return;
        }

        String name = req.getParameter("fullName");
        String address = req.getParameter("address");
        String phone = req.getParameter("phone");

        // Snapshot the items: cart.values() is a live view and would be empty
        // after cart.clear(), leaving the confirmation page with no line items.
        List<CartItem> items = new ArrayList<>(cart.values());

        double total = 0;
        for (CartItem item : items) {
            total += item.getSubtotal();
        }

        // Random suffix avoids collisions when several containers take orders in the same millisecond.
        String orderId = "SM" + System.currentTimeMillis() + ThreadLocalRandom.current().nextInt(100, 1000);

        if (Database.isEnabled()) {
            try {
                OrderRepository.save(orderId, user.getUsername(), name, address, phone, total, items);
            } catch (SQLException e) {
                LOG.log(Level.SEVERE, "Failed to save order " + orderId, e);
                req.setAttribute("error", "We couldn't place your order right now. Please try again in a moment.");
                req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
                return; // cart is kept so the customer can retry
            }
        }

        req.setAttribute("orderId", orderId);
        req.setAttribute("customerName", name);
        req.setAttribute("address", address);
        req.setAttribute("phone", phone);
        req.setAttribute("total", total);
        req.setAttribute("items", items);

        // Clear the cart after a successful order
        cart.clear();

        RequestDispatcher rd = req.getRequestDispatcher("/orderconfirmation.jsp");
        rd.forward(req, resp);
    }
}
