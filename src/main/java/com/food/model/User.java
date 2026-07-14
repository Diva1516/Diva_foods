package com.food.model;

import java.sql.Timestamp;

public class User {
	private int userID;
	private String userName;
	private String email;
	private String password;
	private String confirmPassword;
	private String address;
	private String phoneNumber;
	private String role;
	private Timestamp createdDate;
	private Timestamp lastLoginDate;
	private double totalEarnings;
	
	public User() {
		
	}

	// Full constructor with all fields including phoneNumber
	public User(int userID, String userName, String email, String password, String address, String phoneNumber,
			String role, Timestamp createdDate, Timestamp lastLoginDate) {
		super();
		this.userID = userID;
		this.userName = userName;
		this.email = email;
		this.password = password;
		this.address = address;
		this.phoneNumber = phoneNumber;
		this.role = role;
		this.createdDate = createdDate;
		this.lastLoginDate = lastLoginDate;
	}

	// Backward-compatible: full constructor without phoneNumber
	public User(int userID, String userName, String email, String password, String address, String role,
			Timestamp createdDate, Timestamp lastLoginDate) {
		this(userID, userName, email, password, address, null, role, createdDate, lastLoginDate);
	}

	// Short constructor with phoneNumber
	public User(String userName, String email, String password, String address, String phoneNumber, String role) {
		super();
		this.userName = userName;
		this.email = email;
		this.password = password;
		this.address = address;
		this.phoneNumber = phoneNumber;
		this.role = role;
	}

	// Backward-compatible: short constructor without phoneNumber
	public User(String userName, String email, String password, String address, String role) {
		this(userName, email, password, address, null, role);
	}

	public User(String userName, String email, String password, String address, String phoneNumber, String role, Timestamp createdDate,
			Timestamp lastLoginDate) {
		super();
		this.userName = userName;
		this.email = email;
		this.password = password;
		this.address = address;
		this.phoneNumber = phoneNumber;
		this.role = role;
		this.createdDate = createdDate;
		this.lastLoginDate = lastLoginDate;
	}

	// Backward-compatible: constructor with timestamps without phoneNumber
	public User(String userName, String email, String password, String address, String role, Timestamp createdDate,
			Timestamp lastLoginDate) {
		this(userName, email, password, address, null, role, createdDate, lastLoginDate);
	}

	public int getUserID() {
		return userID;
	}

	public void setUserID(int userID) {
		this.userID = userID;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getPhoneNumber() {
		return phoneNumber;
	}

	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public Timestamp getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Timestamp createdDate) {
		this.createdDate = createdDate;
	}

	public Timestamp getLastLoginDate() {
		return lastLoginDate;
	}

	public void setLastLoginDate(Timestamp lastLoginDate) {
		this.lastLoginDate = lastLoginDate;
	}

	public String getConfirmPassword() {
		return confirmPassword;
	}

	public void setConfirmPassword(String confirmPassword) {
		this.confirmPassword = confirmPassword;
	}

	public double getTotalEarnings() {
		return totalEarnings;
	}

	public void setTotalEarnings(double totalEarnings) {
		this.totalEarnings = totalEarnings;
	}

	@Override
	public String toString() {
		return "User [userID=" + userID + ", userName=" + userName + ", email=" + email + ", password=" + password
				+ ", address=" + address + ", phoneNumber=" + phoneNumber + ", role=" + role + ", createdDate=" + createdDate + ", lastLoginDate="
				+ lastLoginDate + "]";
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}

}
