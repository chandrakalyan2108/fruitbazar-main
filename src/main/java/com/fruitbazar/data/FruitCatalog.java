package com.fruitbazar.data;

import com.fruitbazar.model.Fruit;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * In-memory catalog of fruits available on FruitBazar.
 * In a production system this would be backed by a database (e.g. MySQL)
 * accessed through a DAO layer instead of a static list.
 */
public class FruitCatalog {

    private static final List<Fruit> FRUITS = new ArrayList<>();

    static {
        FRUITS.add(new Fruit(1, "Alphonso Mango", "Tropical", 349.00, "per kg",
                "images/mango.png",
                "Juicy, fragrant Alphonso mangoes — the king of fruits."));

        FRUITS.add(new Fruit(2, "Fuji Apple", "Pome", 219.00, "per kg",
                "images/apple.png",
                "Crisp, sweet Fuji apples, hand-picked and orchard fresh."));

        FRUITS.add(new Fruit(3, "Cavendish Banana", "Tropical", 59.00, "per dozen",
                "images/banana.png",
                "Naturally ripened bananas, soft and energy-packed."));

        FRUITS.add(new Fruit(4, "Valencia Orange", "Citrus", 129.00, "per kg",
                "images/orange.png",
                "Tangy-sweet Valencia oranges, rich in vitamin C."));

        FRUITS.add(new Fruit(5, "Seedless Watermelon", "Melon", 45.00, "per kg",
                "images/watermelon.png",
                "Refreshing, seedless watermelon — perfect for summer."));

        FRUITS.add(new Fruit(6, "Black Grapes", "Berry", 179.00, "per kg",
                "images/grapes.png",
                "Sweet seedless black grapes, chilled and ready to eat."));

        FRUITS.add(new Fruit(7, "Fresh Strawberry", "Berry", 249.00, "per box",
                "images/strawberry.png",
                "Farm-fresh strawberries, bright red and naturally sweet."));

        FRUITS.add(new Fruit(8, "Golden Pineapple", "Tropical", 89.00, "per piece",
                "images/pineapple.png",
                "Sweet, golden pineapple with a tropical aroma."));

        FRUITS.add(new Fruit(9, "Kiwi Fruit", "Exotic", 199.00, "per 4 pcs",
                "images/kiwi.png",
                "Tangy-sweet kiwi, packed with fiber and vitamin C."));

        FRUITS.add(new Fruit(10, "Pomegranate", "Exotic", 189.00, "per kg",
                "images/pomegranate.png",
                "Ruby-red pomegranate arils, sweet and antioxidant-rich."));

        FRUITS.add(new Fruit(11, "Papaya", "Tropical", 65.00, "per piece",
                "images/papaya.png",
                "Ripe, sweet papaya — great for digestion and glowing skin."));

        FRUITS.add(new Fruit(12, "Blueberries", "Berry", 399.00, "per box",
                "images/blueberries.png",
                "Antioxidant-rich blueberries, hand-picked at peak ripeness."));
    }

    private FruitCatalog() {
    }

    public static List<Fruit> getAll() {
        return Collections.unmodifiableList(FRUITS);
    }

    public static Fruit getById(int id) {
        for (Fruit f : FRUITS) {
            if (f.getId() == id) {
                return f;
            }
        }
        return null;
    }
}
