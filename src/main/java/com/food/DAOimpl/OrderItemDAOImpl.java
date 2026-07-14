package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.food.DAO.OrderItemDAO;
import com.food.model.OrderItem;
import com.food.utility.DBConnection;

public class OrderItemDAOImpl implements OrderItemDAO {
    private static final String INSERT_QUERY = "INSERT INTO OrderItem (OrderID, MenuID, Quantity, ItemTotal) VALUES (?, ?, ?, ?)";
    private static final String GET_QUERY = "SELECT * FROM OrderItem WHERE OrderItemID = ?";
    private static final String UPDATE_QUERY = "UPDATE OrderItem SET OrderID = ?, MenuID = ?, Quantity = ?, ItemTotal = ? WHERE OrderItemID = ?";
    private static final String DELETE_QUERY = "DELETE FROM OrderItem WHERE OrderItemID = ?";
    private static final String GET_ALL_QUERY = "SELECT * FROM OrderItem";
    private static final String GET_BY_ORDER_QUERY = "SELECT * FROM OrderItem WHERE OrderID = ?";

    @Override
    public void addOrderItem(OrderItem orderItem) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(INSERT_QUERY)) {
            pstmt.setInt(1, orderItem.getOrderID());
            pstmt.setInt(2, orderItem.getMenuID());
            pstmt.setInt(3, orderItem.getQuantity());
            pstmt.setDouble(4, orderItem.getItemTotal());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public OrderItem getOrderItem(int orderItemId) {
        OrderItem orderItem = null;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_QUERY)) {
            pstmt.setInt(1, orderItemId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    orderItem = extractOrderItemFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderItem;
    }

    @Override
    public void updateOrderItem(OrderItem orderItem) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(UPDATE_QUERY)) {
            pstmt.setInt(1, orderItem.getOrderID());
            pstmt.setInt(2, orderItem.getMenuID());
            pstmt.setInt(3, orderItem.getQuantity());
            pstmt.setDouble(4, orderItem.getItemTotal());
            pstmt.setInt(5, orderItem.getOrderItemID());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteOrderItem(int orderItemId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(DELETE_QUERY)) {
            pstmt.setInt(1, orderItemId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<OrderItem> getAllOrderItems() {
        List<OrderItem> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(GET_ALL_QUERY)) {
            while (rs.next()) {
                list.add(extractOrderItemFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<OrderItem> getOrderItemsByOrder(int orderId) {
        List<OrderItem> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_BY_ORDER_QUERY)) {
            pstmt.setInt(1, orderId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderItemFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private OrderItem extractOrderItemFromResultSet(ResultSet rs) throws SQLException {
        return new OrderItem(
            rs.getInt("OrderItemID"),
            rs.getInt("OrderID"),
            rs.getInt("MenuID"),
            rs.getInt("Quantity"),
            rs.getDouble("ItemTotal")
        );
    }
}
