package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.food.DAO.RestaurantDAO;
import com.food.model.Restaurant;
import com.food.utility.DBConnection;

public class RestaurantDAOImpl implements RestaurantDAO {
    private static final String INSERT_QUERY = "INSERT INTO restaurant (Name, CuisineType, DeliveryTime, Address, AdminUserID, Rating, IsActive, ImagePath) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private static final String GET_QUERY = "SELECT * FROM restaurant WHERE RestaurantID = ?";
    private static final String UPDATE_QUERY = "UPDATE restaurant SET Name = ?, CuisineType = ?, DeliveryTime = ?, Address = ?, AdminUserID = ?, Rating = ?, IsActive = ?, ImagePath = ? WHERE RestaurantID = ?";
    private static final String DELETE_QUERY = "DELETE FROM restaurant WHERE RestaurantID = ?";
    private static final String GET_ALL_QUERY = "SELECT * FROM restaurant";

    @Override
    public void addRestaurant(Restaurant restaurant) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(INSERT_QUERY)) {
            pstmt.setString(1, restaurant.getName());
            pstmt.setString(2, restaurant.getCuisineType());
            pstmt.setInt(3, restaurant.getDeliveryTime());
            pstmt.setString(4, restaurant.getAddress());
            pstmt.setInt(5, restaurant.getAdminUserID());
            pstmt.setDouble(6, restaurant.getRating());
            pstmt.setBoolean(7, restaurant.isActive());
            pstmt.setString(8, restaurant.getImagePath());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Restaurant getRestaurant(int restaurantId) {
        Restaurant restaurant = null;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_QUERY)) {
            pstmt.setInt(1, restaurantId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    restaurant = extractRestaurantFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return restaurant;
    }

    @Override
    public void updateRestaurant(Restaurant restaurant) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(UPDATE_QUERY)) {
            pstmt.setString(1, restaurant.getName());
            pstmt.setString(2, restaurant.getCuisineType());
            pstmt.setInt(3, restaurant.getDeliveryTime());
            pstmt.setString(4, restaurant.getAddress());
            pstmt.setInt(5, restaurant.getAdminUserID());
            pstmt.setDouble(6, restaurant.getRating());
            pstmt.setBoolean(7, restaurant.isActive());
            pstmt.setString(8, restaurant.getImagePath());
            pstmt.setInt(9, restaurant.getRestaurantID());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteRestaurant(int restaurantId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(DELETE_QUERY)) {
            pstmt.setInt(1, restaurantId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(GET_ALL_QUERY)) {
            while (rs.next()) {
                list.add(extractRestaurantFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Restaurant extractRestaurantFromResultSet(ResultSet rs) throws SQLException {
        return new Restaurant(
            rs.getInt("RestaurantID"),
            rs.getString("Name"),
            rs.getString("CuisineType"),
            rs.getInt("DeliveryTime"),
            rs.getString("Address"),
            rs.getInt("AdminUserID"),
            rs.getDouble("Rating"),
            rs.getBoolean("IsActive"),
            rs.getString("ImagePath")
        );
    }
}
