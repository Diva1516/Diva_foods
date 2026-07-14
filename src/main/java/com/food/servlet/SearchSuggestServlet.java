package com.food.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.food.utility.DBConnection;

@WebServlet("/searchSuggest")
public class SearchSuggestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String query = request.getParameter("q");
        PrintWriter out = response.getWriter();
        
        if (query == null || query.trim().length() < 2) {
            out.print("[]");
            return;
        }
        
        // Typo tolerance
        String searchString = query.trim().replaceAll("(?i)biriyani", "biryani");
        
        query = "%" + searchString + "%";
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        int count = 0;
        
        // 1. Search Restaurants
        String restSql = "SELECT RestaurantID, Name FROM restaurant WHERE Name LIKE ? OR CuisineType LIKE ? LIMIT 4";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(restSql)) {
            pstmt.setString(1, query);
            pstmt.setString(2, query);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next() && count < 8) {
                    if (!first) json.append(",");
                    first = false;
                    
                    int id = rs.getInt("RestaurantID");
                    String name = escapeJson(rs.getString("Name"));
                    
                    json.append("{")
                        .append("\"id\":").append(id).append(",")
                        .append("\"text\":\"").append(name).append("\",")
                        .append("\"type\":\"restaurant\"")
                        .append("}");
                    count++;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // 2. Search Menu Items
        String menuSql = "SELECT MenuID, RestaurantID, ItemName FROM menu WHERE ItemName LIKE ? LIMIT 4";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(menuSql)) {
            pstmt.setString(1, query);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next() && count < 8) {
                    if (!first) json.append(",");
                    first = false;
                    
                    int id = rs.getInt("RestaurantID");
                    String name = escapeJson(rs.getString("ItemName"));
                    
                    json.append("{")
                        .append("\"id\":").append(id).append(",")
                        .append("\"text\":\"").append(name).append("\",")
                        .append("\"type\":\"dish\"")
                        .append("}");
                    count++;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        json.append("]");
        out.print(json.toString());
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
