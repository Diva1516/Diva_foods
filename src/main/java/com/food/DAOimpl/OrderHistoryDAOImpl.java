package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.food.DAO.OrderHistoryDAO;
import com.food.model.OrderHistory;
import com.food.utility.DBConnection;

public class OrderHistoryDAOImpl implements OrderHistoryDAO {
    private static final String INSERT_QUERY = "INSERT INTO orderhistory (OrderID, UserID, OrderDate, TotalAmount, Status) VALUES (?, ?, ?, ?, ?)";
    private static final String GET_QUERY = "SELECT * FROM orderhistory WHERE OrderHistoryID = ?";
    private static final String UPDATE_QUERY = "UPDATE orderhistory SET OrderID = ?, UserID = ?, OrderDate = ?, TotalAmount = ?, Status = ? WHERE OrderHistoryID = ?";
    private static final String DELETE_QUERY = "DELETE FROM orderhistory WHERE OrderHistoryID = ?";
    private static final String GET_ALL_QUERY = "SELECT * FROM orderhistory";
    private static final String GET_BY_USER_QUERY = "SELECT * FROM orderhistory WHERE UserID = ?";

    @Override
    public void addOrderHistory(OrderHistory orderHistory) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(INSERT_QUERY)) {
            pstmt.setInt(1, orderHistory.getOrderID());
            pstmt.setInt(2, orderHistory.getUserID());
            pstmt.setTimestamp(3, orderHistory.getOrderDate() != null ? orderHistory.getOrderDate() : new Timestamp(System.currentTimeMillis()));
            pstmt.setDouble(4, orderHistory.getTotalAmount());
            pstmt.setString(5, orderHistory.getStatus());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public OrderHistory getOrderHistory(int orderHistoryId) {
        OrderHistory orderHistory = null;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_QUERY)) {
            pstmt.setInt(1, orderHistoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    orderHistory = extractOrderHistoryFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderHistory;
    }

    @Override
    public void updateOrderHistory(OrderHistory orderHistory) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(UPDATE_QUERY)) {
            pstmt.setInt(1, orderHistory.getOrderID());
            pstmt.setInt(2, orderHistory.getUserID());
            pstmt.setTimestamp(3, orderHistory.getOrderDate());
            pstmt.setDouble(4, orderHistory.getTotalAmount());
            pstmt.setString(5, orderHistory.getStatus());
            pstmt.setInt(6, orderHistory.getOrderHistoryID());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteOrderHistory(int orderHistoryId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(DELETE_QUERY)) {
            pstmt.setInt(1, orderHistoryId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<OrderHistory> getAllOrderHistories() {
        List<OrderHistory> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(GET_ALL_QUERY)) {
            while (rs.next()) {
                list.add(extractOrderHistoryFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<OrderHistory> getOrderHistoriesByUser(int userId) {
        List<OrderHistory> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_BY_USER_QUERY)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderHistoryFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private OrderHistory extractOrderHistoryFromResultSet(ResultSet rs) throws SQLException {
        return new OrderHistory(
            rs.getInt("OrderHistoryID"),
            rs.getInt("OrderID"),
            rs.getInt("UserID"),
            rs.getTimestamp("OrderDate"),
            rs.getDouble("TotalAmount"),
            rs.getString("Status")
        );
    }
}
