package com.food.DAO;

import java.util.List;
import com.food.model.Order;

public interface OrderDAO {
    // Returns the generated Order ID
    int addOrder(Order order);
    Order getOrder(int orderId);
    void updateOrder(Order order);
    void deleteOrder(int orderId);
    List<Order> getAllOrders();
    List<Order> getOrdersByUser(int userId);
    List<Order> getOrdersByRestaurant(int restaurantId);
    void updateOrderStatus(int orderId, String status);
    List<Order> getPendingOrders();
    List<Order> getOrdersByDeliveryAgent(int agentId);
}
