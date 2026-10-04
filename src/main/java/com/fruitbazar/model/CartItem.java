package com.fruitbazar.model;

import java.io.Serializable;

/**
 * Represents one line item (fruit + quantity) inside a shopping cart.
 */
public class CartItem implements Serializable {

    private final Fruit fruit;
    private int quantity;

    public CartItem(Fruit fruit, int quantity) {
        this.fruit = fruit;
        this.quantity = quantity;
    }

    public Fruit getFruit() {
        return fruit;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getSubtotal() {
        return fruit.getPrice() * quantity;
    }
}
