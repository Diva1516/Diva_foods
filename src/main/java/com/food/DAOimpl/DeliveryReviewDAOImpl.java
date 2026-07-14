package com.food.DAOimpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.food.model.DeliveryReview;
import com.food.utility.DBConnection;

public class DeliveryReviewDAOImpl {

    public boolean addReview(DeliveryReview review) {
        String query = "INSERT INTO DeliveryReview (OrderID, CustomerID, AgentID, Rating, Comments) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(query)) {
            
            pstmt.setInt(1, review.getOrderID());
            pstmt.setInt(2, review.getCustomerID());
            pstmt.setInt(3, review.getAgentID());
            pstmt.setInt(4, review.getRating());
            pstmt.setString(5, review.getComments());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<DeliveryReview> getReviewsByAgent(int agentId) {
        List<DeliveryReview> reviews = new ArrayList<>();
        String query = "SELECT * FROM DeliveryReview WHERE AgentID = ? ORDER BY ReviewDate DESC";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(query)) {
            
            pstmt.setInt(1, agentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(new DeliveryReview(
                        rs.getInt("ReviewID"),
                        rs.getInt("OrderID"),
                        rs.getInt("CustomerID"),
                        rs.getInt("AgentID"),
                        rs.getInt("Rating"),
                        rs.getString("Comments"),
                        rs.getTimestamp("ReviewDate")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reviews;
    }
    
    public double getAverageRating(int agentId) {
        String query = "SELECT AVG(Rating) as avgRating FROM DeliveryReview WHERE AgentID = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(query)) {
            
            pstmt.setInt(1, agentId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avgRating");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}
