package com.food.model;

import java.util.HashMap;
import java.util.Map;

/**
 * Cart model class. Contains cart items map and operations to add, update, remove, and get total price.
 */
public class Cart implements java.io.Serializable {
    private static final long serialVersionUID = 1L;
    private Map<Integer, CartItem> items;

    public Cart() {
        items = new HashMap<>();
    }

    public Map<Integer, CartItem> getItems() {
        return items;
    }

    public void addItem(CartItem cartItem) {
        int menuId = cartItem.getMenuId();
        if (items.containsKey(menuId)) {
            CartItem existingItem = items.get(menuId);
            existingItem.setQuantity(existingItem.getQuantity() + cartItem.getQuantity());
        } else {
            items.put(menuId, cartItem);
        }
    }

    public void updateItem(int itemId, int quantity) {
        if (items.containsKey(itemId)) {
            if (quantity <= 0) {
                items.remove(itemId);
            } else {
                items.get(itemId).setQuantity(quantity);
            }
        }
    }

    public void removeItem(int itemId) {
        items.remove(itemId);
    }

    public void clearCart() {
        items.clear();
    }

    public double getTotalPrice() {
        double total = 0;
        for (CartItem item : items.values()) {
            total += item.getTotalPrice();
        }
        return total;
    }

    public int getItemCount() {
        int count = 0;
        for (CartItem item : items.values()) {
            count += item.getQuantity();
        }
        return count;
    }

    public boolean isEmpty() {
        return items.isEmpty();
    }
}
