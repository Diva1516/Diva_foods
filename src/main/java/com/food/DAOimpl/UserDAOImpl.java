package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.food.DAO.UserDAO;
import com.food.model.User;
import com.food.utility.DBConnection;

public class UserDAOImpl implements UserDAO {
     private static final String INSERT_QUERY = "INSERT INTO User (Username, Email, Password, ConfirmPassword, Address, PhoneNumber, Role, CreatedDate, LastLoginDate, TotalEarnings) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
     private static final String GET_QUERY = "SELECT * FROM User WHERE UserID = ?";
     private static final String UPDATE_USER = "UPDATE User SET Username = ?, Email = ?, Password = ?, Address = ?, PhoneNumber = ?, LastLoginDate = ? WHERE UserID = ?";
     private static final String DELETE_USER = "DELETE FROM User WHERE UserID = ?";
     private static final String GET_ALL_USER = "SELECT * FROM User";

     @Override
     public User getUserByUsername(String username) {
        User user = null;
        String sql = "SELECT * FROM User WHERE Username = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
     }

     @Override
     public User getUserByEmail(String email) {
        User user = null;
        String sql = "SELECT * FROM User WHERE Email = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = extractUserFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
     }

     @Override
     public int addUser(User user) {
         try (Connection connection = DBConnection.getConnection();
              PreparedStatement pstmt = connection.prepareStatement(INSERT_QUERY)) {
             pstmt.setString(1, user.getUserName());
             pstmt.setString(2, user.getEmail());
             pstmt.setString(3, user.getPassword());
             pstmt.setString(4, user.getConfirmPassword());
             pstmt.setString(5, user.getAddress());
             pstmt.setString(6, user.getPhoneNumber());
             pstmt.setString(7, user.getRole());
             pstmt.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
             pstmt.setTimestamp(9, new Timestamp(System.currentTimeMillis()));
             pstmt.setDouble(10, user.getTotalEarnings());
             int i = pstmt.executeUpdate();
             return i;
         } catch (SQLException e) {
             e.printStackTrace();
         }
         return 0;
     }

     @Override
     public User getUser(int userID) {
         User user = null;
         try (Connection connection = DBConnection.getConnection();
              PreparedStatement pstmt = connection.prepareStatement(GET_QUERY)) {
             pstmt.setInt(1, userID);
             try (ResultSet rs = pstmt.executeQuery()) {
                 if (rs.next()) {
                     user = extractUserFromResultSet(rs);
                 }
             }
         } catch (SQLException e) {
             e.printStackTrace();
         }
         return user;
     }

     @Override
     public void updateUser(User user) {
         try (Connection connection = DBConnection.getConnection();
              PreparedStatement pstmt = connection.prepareStatement("UPDATE User SET Username = ?, Email = ?, Password = ?, ConfirmPassword = ?, Address = ?, PhoneNumber = ?, LastLoginDate = ?, TotalEarnings = ? WHERE UserID = ?")) {
             pstmt.setString(1, user.getUserName());
             pstmt.setString(2, user.getEmail());
             pstmt.setString(3, user.getPassword());
             pstmt.setString(4, user.getConfirmPassword());
             pstmt.setString(5, user.getAddress());
             pstmt.setString(6, user.getPhoneNumber());
             pstmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
             pstmt.setDouble(8, user.getTotalEarnings());
             pstmt.setInt(9, user.getUserID());
             pstmt.executeUpdate();
         } catch (SQLException e) {
             e.printStackTrace();
         }
     }

     @Override
     public void deleteUser(int userId) {
         try (Connection connection = DBConnection.getConnection();
              PreparedStatement pstmt = connection.prepareStatement(DELETE_USER)) {
             pstmt.setInt(1, userId);
             pstmt.executeUpdate();
         } catch (SQLException e) {
             e.printStackTrace();
         }
     }

     @Override
     public List<User> getAllUser() {
         List<User> list = new ArrayList<>();
         try (Connection connection = DBConnection.getConnection();
              Statement stmt = connection.createStatement();
              ResultSet rs = stmt.executeQuery(GET_ALL_USER)) {
             while (rs.next()) {
                 list.add(extractUserFromResultSet(rs));
             }
         } catch (SQLException e) {
              e.printStackTrace();
         }
         return list;
     }

     public static User extractUserFromResultSet(ResultSet rs) throws SQLException {
         User user = new User(
             rs.getInt("UserID"),
             rs.getString("Username"),
             rs.getString("Email"),
             rs.getString("Password"),
             rs.getString("Address"),
             rs.getString("PhoneNumber"),
             rs.getString("Role"),
             rs.getTimestamp("CreatedDate"),
             rs.getTimestamp("LastLoginDate")
         );
         try {
             user.setConfirmPassword(rs.getString("ConfirmPassword"));
             user.setTotalEarnings(rs.getDouble("TotalEarnings"));
         } catch(SQLException e) {
             // Handle gracefully if columns don't exist yet in certain queries
         }
         return user;
     }
}
