package com.fruitbazar.data;

import com.fruitbazar.model.CartItem;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Collection;

/**
 * Persists placed orders (and their line items) to MySQL in one transaction.
 */
public final class OrderRepository {

    private OrderRepository() {
    }

    public static void save(String orderId, String username, String customerName, String address,
                            String phone, double total, Collection<CartItem> items) throws SQLException {
        try (Connection con = Database.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO orders (id, username, customer_name, address, phone, total) "
                                + "VALUES (?, ?, ?, ?, ?, ?)")) {
                    ps.setString(1, orderId);
                    ps.setString(2, username);
                    ps.setString(3, customerName);
                    ps.setString(4, address);
                    ps.setString(5, phone);
                    ps.setBigDecimal(6, money(total));
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO order_items (order_id, fruit_id, fruit_name, unit_price, quantity, subtotal) "
                                + "VALUES (?, ?, ?, ?, ?, ?)")) {
                    for (CartItem item : items) {
                        ps.setString(1, orderId);
                        ps.setInt(2, item.getFruit().getId());
                        ps.setString(3, item.getFruit().getName());
                        ps.setBigDecimal(4, money(item.getFruit().getPrice()));
                        ps.setInt(5, item.getQuantity());
                        ps.setBigDecimal(6, money(item.getSubtotal()));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
        }
    }

    private static BigDecimal money(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP);
    }
}
