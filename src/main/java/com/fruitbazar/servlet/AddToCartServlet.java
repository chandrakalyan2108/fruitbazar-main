package com.fruitbazar.servlet;

import com.fruitbazar.data.FruitCatalog;
import com.fruitbazar.model.CartItem;
import com.fruitbazar.model.Fruit;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/addToCart")
public class AddToCartServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int fruitId = parseIntOrDefault(req.getParameter("fruitId"), -1);
        int quantity = parseIntOrDefault(req.getParameter("quantity"), 1);
        if (quantity < 1) quantity = 1;

        Fruit fruit = FruitCatalog.getById(fruitId);
        if (fruit != null) {
            HttpSession session = req.getSession();
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            if (cart == null) {
                cart = new LinkedHashMap<>();
                session.setAttribute("cart", cart);
            }

            CartItem existing = cart.get(fruitId);
            if (existing != null) {
                existing.setQuantity(existing.getQuantity() + quantity);
            } else {
                cart.put(fruitId, new CartItem(fruit, quantity));
            }
        }

        String referer = req.getHeader("Referer");
        resp.sendRedirect(referer != null ? referer : req.getContextPath() + "/fruits.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }

    private int parseIntOrDefault(String value, int defaultVal) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultVal;
        }
    }
}
