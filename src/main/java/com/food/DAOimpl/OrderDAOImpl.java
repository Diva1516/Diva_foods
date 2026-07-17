package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.food.DAO.OrderDAO;
import com.food.model.Order;
import com.food.utility.DBConnection;

public class OrderDAOImpl implements OrderDAO {
    private static final String INSERT_QUERY = "INSERT INTO ordertable (UserID, RestaurantID, OrderDate, TotalAmount, Status, PaymentMethod, DeliveryAgentID) VALUES (?, ?, ?, ?, ?, ?, ?)";
    private static final String GET_QUERY = "SELECT * FROM ordertable WHERE OrderID = ?";
    private static final String UPDATE_QUERY = "UPDATE ordertable SET UserID = ?, RestaurantID = ?, OrderDate = ?, TotalAmount = ?, Status = ?, PaymentMethod = ?, DeliveryAgentID = ? WHERE OrderID = ?";
    private static final String DELETE_QUERY = "DELETE FROM ordertable WHERE OrderID = ?";
    private static final String GET_ALL_QUERY = "SELECT * FROM ordertable";
    private static final String GET_BY_USER_QUERY = "SELECT * FROM ordertable WHERE UserID = ? ORDER BY OrderDate DESC";
    private static final String GET_BY_RESTAURANT_QUERY = "SELECT * FROM ordertable WHERE RestaurantID = ? ORDER BY OrderDate DESC";
    private static final String GET_PENDING_QUERY = "SELECT * FROM ordertable WHERE Status IN ('pending', 'preparing') AND DeliveryAgentID IS NULL ORDER BY OrderDate ASC";
    private static final String GET_BY_AGENT_QUERY = "SELECT * FROM ordertable WHERE DeliveryAgentID = ? ORDER BY OrderDate DESC";

    @Override
    public int addOrder(Order order) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(INSERT_QUERY, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, order.getUserID());
            pstmt.setInt(2, order.getRestaurantID());
            pstmt.setTimestamp(3, order.getOrderDate() != null ? order.getOrderDate() : new Timestamp(System.currentTimeMillis()));
            pstmt.setDouble(4, order.getTotalAmount());
            pstmt.setString(5, order.getStatus());
            pstmt.setString(6, order.getPaymentMethod());
            if (order.getDeliveryAgentId() != null) {
                pstmt.setInt(7, order.getDeliveryAgentId());
            } else {
                pstmt.setNull(7, java.sql.Types.INTEGER);
            }
            
            pstmt.executeUpdate();
            
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // Return generated OrderID
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public Order getOrder(int orderId) {
        Order order = null;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_QUERY)) {
            pstmt.setInt(1, orderId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    order = extractOrderFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return order;
    }

    @Override
    public void updateOrder(Order order) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(UPDATE_QUERY)) {
            pstmt.setInt(1, order.getUserID());
            pstmt.setInt(2, order.getRestaurantID());
            pstmt.setTimestamp(3, order.getOrderDate());
            pstmt.setDouble(4, order.getTotalAmount());
            pstmt.setString(5, order.getStatus());
            pstmt.setString(6, order.getPaymentMethod());
            if (order.getDeliveryAgentId() != null) {
                pstmt.setInt(7, order.getDeliveryAgentId());
            } else {
                pstmt.setNull(7, java.sql.Types.INTEGER);
            }
            pstmt.setInt(8, order.getOrderID());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteOrder(int orderId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(DELETE_QUERY)) {
            pstmt.setInt(1, orderId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(GET_ALL_QUERY)) {
            while (rs.next()) {
                list.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Order> getOrdersByUser(int userId) {
        List<Order> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_BY_USER_QUERY)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Order> getOrdersByRestaurant(int restaurantId) {
        List<Order> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_BY_RESTAURANT_QUERY)) {
            pstmt.setInt(1, restaurantId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getPendingOrders() {
        List<Order> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(GET_PENDING_QUERY)) {
            while (rs.next()) {
                list.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Order> getOrdersByDeliveryAgent(int agentId) {
        List<Order> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_BY_AGENT_QUERY)) {
            pstmt.setInt(1, agentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractOrderFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order order = new Order(
            rs.getInt("OrderID"),
            rs.getInt("UserID"),
            rs.getInt("RestaurantID"),
            rs.getTimestamp("OrderDate"),
            rs.getDouble("TotalAmount"),
            rs.getString("Status"),
            rs.getString("PaymentMethod")
        );
        int agentId = rs.getInt("DeliveryAgentID");
        if (!rs.wasNull()) {
            order.setDeliveryAgentId(agentId);
        }
        return order;
    }

    @Override
    public void updateOrderStatus(int orderId, String status) {
        String query = "UPDATE ordertable SET Status = ? WHERE OrderID = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(query)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, orderId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
