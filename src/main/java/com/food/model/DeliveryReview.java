package com.food.model;

import java.sql.Timestamp;

public class DeliveryReview {
    private int reviewID;
    private int orderID;
    private int customerID;
    private int agentID;
    private int rating;
    private String comments;
    private Timestamp reviewDate;

    public DeliveryReview() {
    }

    public DeliveryReview(int orderID, int customerID, int agentID, int rating, String comments) {
        this.orderID = orderID;
        this.customerID = customerID;
        this.agentID = agentID;
        this.rating = rating;
        this.comments = comments;
    }

    public DeliveryReview(int reviewID, int orderID, int customerID, int agentID, int rating, String comments, Timestamp reviewDate) {
        this.reviewID = reviewID;
        this.orderID = orderID;
        this.customerID = customerID;
        this.agentID = agentID;
        this.rating = rating;
        this.comments = comments;
        this.reviewDate = reviewDate;
    }

    public int getReviewID() { return reviewID; }
    public void setReviewID(int reviewID) { this.reviewID = reviewID; }
    
    public int getOrderID() { return orderID; }
    public void setOrderID(int orderID) { this.orderID = orderID; }
    
    public int getCustomerID() { return customerID; }
    public void setCustomerID(int customerID) { this.customerID = customerID; }
    
    public int getAgentID() { return agentID; }
    public void setAgentID(int agentID) { this.agentID = agentID; }
    
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    
    public String getComments() { return comments; }
    public void setComments(String comments) { this.comments = comments; }
    
    public Timestamp getReviewDate() { return reviewDate; }
    public void setReviewDate(Timestamp reviewDate) { this.reviewDate = reviewDate; }
}
