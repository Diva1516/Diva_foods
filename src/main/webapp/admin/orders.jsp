<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Order, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<Order> orderList = (List<Order>) request.getAttribute("orderList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - Admin Dashboard</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css">
    <style>
        select option {
            background-color: var(--bg-card, #1a1a1a);
            color: var(--text-primary, #ffffff);
        }
    </style>
</head>
<body>
    <header>
        <nav class="navbar">
            <div class="container">
                <a href="dashboard" class="nav-logo">
                    <img src="../images/logo.png" alt="Diva Foods Logo" class="brand-logo-img">
                    <span>Diva <span>Foods</span></span>
                </a>
                <div class="nav-actions">
                    <span>Hello! <%= currentUser.getUserName() %> <span style="color: red;">&hearts;</span></span>
                    <button class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle theme">☀️</button>
                    <a href="../logout" class="btn btn-danger btn-sm">Sign Out</a>
                </div>
            </div>
        </nav>
    </header>

    <div class="admin-layout">
        <aside class="admin-sidebar">
            <h3>Management</h3>
            <a href="dashboard">Dashboard</a>
            <a href="users">Manage Users</a>
            <a href="restaurants">Manage Restaurants</a>
            <a href="orders" class="active">Manage Orders</a>
        </aside>

        <main class="admin-main">
            <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Manage Platform Orders</h1>

            <div class="table-card">
                <h2>All Platform Orders</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>User ID</th>
                            <th>Restaurant ID</th>
                            <th>Date</th>
                            <th>Amount</th>
                            <th>Payment</th>
                            <th>Current Status</th>
                            <th>Update Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (orderList == null || orderList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="8" style="text-align: center; color: var(--text-muted);">No orders found.</td>
                            </tr>
                        <%
                            } else {
                                for (Order order : orderList) {
                        %>
                                    <tr>
                                        <td><%= String.format("DF-%04d", order.getOrderID()) %></td>
                                        <td><%= order.getUserID() %></td>
                                        <td><%= order.getRestaurantID() %></td>
                                        <td><%= order.getOrderDate() %></td>
                                        <td>₹<%= String.format(java.util.Locale.US, "%.2f", order.getTotalAmount()) %></td>
                                        <td><%= order.getPaymentMethod() %></td>
                                        <td>
                                            <span class="badge badge-<%= order.getStatus().toLowerCase() %>">
                                                <%= order.getStatus() %>
                                            </span>
                                        </td>
                                        <td>
                                            <!-- Update Status Form -->
                                            <form action="orders" method="POST" style="display: flex; gap: 8px; align-items: center; margin: 0;">
                                                <input type="hidden" name="action" value="updateStatus">
                                                <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                                <select name="status" style="background: var(--bg-card, #1a1a1a); border: 1px solid var(--border); color: var(--text-primary); padding: 4px 8px; border-radius: 4px; font-size: 0.85rem;">
                                                    <option value="Pending" <%= "Pending".equalsIgnoreCase(order.getStatus()) ? "selected" : "" %>>Pending</option>
                                                    <option value="Preparing" <%= "Preparing".equalsIgnoreCase(order.getStatus()) ? "selected" : "" %>>Preparing</option>
                                                    <option value="Ready" <%= "Ready".equalsIgnoreCase(order.getStatus()) ? "selected" : "" %>>Ready</option>
                                                    <option value="Delivered" <%= "Delivered".equalsIgnoreCase(order.getStatus()) ? "selected" : "" %>>Delivered</option>
                                                    <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(order.getStatus()) ? "selected" : "" %>>Cancelled</option>
                                                </select>
                                                <button type="submit" class="btn btn-primary btn-sm" style="padding: 4px 8px; font-size: 0.8rem;">Update</button>
                                            </form>
                                        </td>
                                    </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <footer></footer>
    <script src="../js/app.js"></script>
</body>
</html>


