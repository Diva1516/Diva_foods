package com.food.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.food.model.Menu;
import com.food.model.Restaurant;
import com.food.utility.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String query = req.getParameter("query");
        if (query == null || query.trim().isEmpty()) {
            resp.sendRedirect("callRestaurantServlet");
            return;
        }

        query = query.trim();
        
        // Typo tolerance: auto-correct common misspelled dishes for better search results
        String searchString = query.replaceAll("(?i)biriyani", "biryani");
        
        List<Restaurant> matchingRestaurants = new ArrayList<>();
        List<Menu> matchingMenus = new ArrayList<>();

        String wildcard = "%" + searchString + "%";

        String restQuery = "SELECT * FROM restaurant WHERE Name LIKE ? OR CuisineType LIKE ?";
        String menuQuery = "SELECT * FROM menu WHERE ItemName LIKE ? OR Description LIKE ?";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch matching restaurants
            try (PreparedStatement pstmt = conn.prepareStatement(restQuery)) {
                pstmt.setString(1, wildcard);
                pstmt.setString(2, wildcard);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        matchingRestaurants.add(new Restaurant(
                            rs.getInt("RestaurantID"),
                            rs.getString("Name"),
                            rs.getString("CuisineType"),
                            rs.getInt("DeliveryTime"),
                            rs.getString("Address"),
                            rs.getInt("AdminUserID"),
                            rs.getDouble("Rating"),
                            rs.getBoolean("IsActive"),
                            rs.getString("ImagePath")
                        ));
                    }
                }
            }

            // 2. Fetch matching menus
            try (PreparedStatement pstmt = conn.prepareStatement(menuQuery)) {
                pstmt.setString(1, wildcard);
                pstmt.setString(2, wildcard);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        matchingMenus.add(new Menu(
                            rs.getInt("MenuID"),
                            rs.getInt("RestaurantID"),
                            rs.getString("ItemName"),
                            rs.getString("Description"),
                            rs.getDouble("Price"),
                            rs.getBoolean("IsAvailable"),
                            rs.getString("ImagePath")
                        ));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("query", query);
        req.setAttribute("matchingRestaurants", matchingRestaurants);
        req.setAttribute("matchingMenus", matchingMenus);

        req.getRequestDispatcher("search.jsp").forward(req, resp);
    }
}
