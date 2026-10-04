package com.fruitbazar.model;

import java.io.Serializable;

/**
 * Represents a single fruit product available for purchase.
 */
public class Fruit implements Serializable {

    private final int id;
    private final String name;
    private final String category;
    private final double price;
    private final String unit;
    private final String imageUrl;
    private final String description;

    public Fruit(int id, String name, String category, double price, String unit,
                 String imageUrl, String description) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.unit = unit;
        this.imageUrl = imageUrl;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getCategory() {
        return category;
    }

    public double getPrice() {
        return price;
    }

    public String getUnit() {
        return unit;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public String getDescription() {
        return description;
    }
}
