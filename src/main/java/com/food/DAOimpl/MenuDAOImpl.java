package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.food.DAO.MenuDAO;
import com.food.model.Menu;
import com.food.utility.DBConnection;

public class MenuDAOImpl implements MenuDAO {
    private static final String INSERT_QUERY = "INSERT INTO menu (RestaurantID, ItemName, Description, Price, IsAvailable, ImagePath) VALUES (?, ?, ?, ?, ?, ?)";
    private static final String GET_QUERY = "SELECT * FROM menu WHERE MenuID = ?";
    private static final String UPDATE_QUERY = "UPDATE menu SET RestaurantID = ?, ItemName = ?, Description = ?, Price = ?, IsAvailable = ?, ImagePath = ? WHERE MenuID = ?";
    private static final String DELETE_QUERY = "DELETE FROM menu WHERE MenuID = ?";
    private static final String GET_ALL_QUERY = "SELECT * FROM menu";
    private static final String GET_BY_RESTAURANT_QUERY = "SELECT * FROM menu WHERE RestaurantID = ?";

    @Override
    public void addMenu(Menu menu) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(INSERT_QUERY)) {
            pstmt.setInt(1, menu.getRestaurantID());
            pstmt.setString(2, menu.getItemName());
            pstmt.setString(3, menu.getDescription());
            pstmt.setDouble(4, menu.getPrice());
            pstmt.setBoolean(5, menu.isAvailable());
            pstmt.setString(6, menu.getImagePath());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Menu getMenu(int menuId) {
        Menu menu = null;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_QUERY)) {
            pstmt.setInt(1, menuId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    menu = extractMenuFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return menu;
    }

    @Override
    public void updateMenu(Menu menu) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(UPDATE_QUERY)) {
            pstmt.setInt(1, menu.getRestaurantID());
            pstmt.setString(2, menu.getItemName());
            pstmt.setString(3, menu.getDescription());
            pstmt.setDouble(4, menu.getPrice());
            pstmt.setBoolean(5, menu.isAvailable());
            pstmt.setString(6, menu.getImagePath());
            pstmt.setInt(7, menu.getMenuID());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteMenu(int menuId) {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(DELETE_QUERY)) {
            pstmt.setInt(1, menuId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Menu> getAllMenus() {
        List<Menu> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(GET_ALL_QUERY)) {
            while (rs.next()) {
                list.add(extractMenuFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Menu> getMenusByRestaurant(int restaurantId) {
        List<Menu> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(GET_BY_RESTAURANT_QUERY)) {
            pstmt.setInt(1, restaurantId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(extractMenuFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Menu extractMenuFromResultSet(ResultSet rs) throws SQLException {
        return new Menu(
            rs.getInt("MenuID"),
            rs.getInt("RestaurantID"),
            rs.getString("ItemName"),
            rs.getString("Description"),
            rs.getDouble("Price"),
            rs.getBoolean("IsAvailable"),
            rs.getString("ImagePath")
        );
    }
}
