package com.food.model;

/**
 * CartItem model representing a single menu item added to the cart.
 */
public class CartItem implements java.io.Serializable {
    private static final long serialVersionUID = 1L;
    private int menuId;
    private int restaurantId;
    private String name;
    private double price; // Changed to double to match Menu model
    private int quantity;
    private String imagePath;

    public CartItem() {}

    public CartItem(int menuId, int restaurantId, String name, double price, int quantity) {
        this.menuId = menuId;
        this.restaurantId = restaurantId;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
    }

    public CartItem(int menuId, int restaurantId, String name, double price, int quantity, String imagePath) {
        this.menuId = menuId;
        this.restaurantId = restaurantId;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.imagePath = imagePath;
    }

    public int getMenuId() { return menuId; }
    public void setMenuId(int menuId) { this.menuId = menuId; }
    public int getRestaurantId() { return restaurantId; }
    public void setRestaurantId(int restaurantId) { this.restaurantId = restaurantId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public double getTotalPrice() {
        return price * quantity;
    }

    @Override
    public String toString() {
        return "CartItem [menuId=" + menuId + ", name=" + name + ", price=" + price + ", quantity=" + quantity + "]";
    }
}