package com.food.DAO;

import java.util.List;
import com.food.model.OrderHistory;

public interface OrderHistoryDAO {
    void addOrderHistory(OrderHistory orderHistory);
    OrderHistory getOrderHistory(int orderHistoryId);
    void updateOrderHistory(OrderHistory orderHistory);
    void deleteOrderHistory(int orderHistoryId);
    List<OrderHistory> getAllOrderHistories();
    List<OrderHistory> getOrderHistoriesByUser(int userId);
}
