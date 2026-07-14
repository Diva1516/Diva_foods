package com.food.model;

import java.sql.Timestamp;

public class OrderHistory {
    private int orderHistoryID;
    private int orderID;
    private int userID;
    private Timestamp orderDate;
    private double totalAmount;
    private String status;

    public OrderHistory() {
    }

    public OrderHistory(int orderHistoryID, int orderID, int userID, Timestamp orderDate, double totalAmount, String status) {
        this.orderHistoryID = orderHistoryID;
        this.orderID = orderID;
        this.userID = userID;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    public OrderHistory(int orderID, int userID, double totalAmount, String status) {
        this.orderID = orderID;
        this.userID = userID;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    public OrderHistory(int orderID, int userID, Timestamp orderDate, double totalAmount, String status) {
        this.orderID = orderID;
        this.userID = userID;
        this.orderDate = orderDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    public int getOrderHistoryID() {
        return orderHistoryID;
    }

    public void setOrderHistoryID(int orderHistoryID) {
        this.orderHistoryID = orderHistoryID;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public Timestamp getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Timestamp orderDate) {
        this.orderDate = orderDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "OrderHistory [orderHistoryID=" + orderHistoryID + ", orderID=" + orderID + ", userID=" + userID
                + ", orderDate=" + orderDate + ", totalAmount=" + totalAmount + ", status=" + status + "]";
    }
}
