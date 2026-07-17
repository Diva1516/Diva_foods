<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Order, com.food.model.Restaurant, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Restaurant myRestaurant = (Restaurant) session.getAttribute("myRestaurant");
    List<Order> orderList = (List<Order>) request.getAttribute("orderList");
    List<Restaurant> myRestaurants = (List<Restaurant>) request.getAttribute("myRestaurants"); // Ensure Servlet sets this!
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order History - Restaurant Dashboard</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css"> <!-- Reuse dashboard metrics and tables stylesheet -->
    <link rel="stylesheet" href="../css/restaurant-owner.css">
</head>
<body>
    <header>
        <nav class="navbar">
            <div class="container">
                <a href="../callRestaurantServlet" class="nav-logo" style="text-decoration: none; display: flex; align-items: center; gap: 12px;">
                    <img src="../images/logo.png" alt="Diva Foods Logo" class="brand-logo-img" style="height: 44px; width: auto; object-fit: contain; border-radius: 10px;">
                    <span class="brand-text" style="font-family: var(--font-heading); font-size: 1.8rem; font-weight: 800; margin-top: -4px;">Diva Foods</span>
                </a>

                <div class="nav-links">
                    <a href="../index.jsp">Home</a>
                    <a href="../callRestaurantServlet">Restaurants</a>
                    <a href="dashboard">Owner Dashboard</a>
                </div>
                <div class="nav-actions">
                    <button class="theme-toggle" onclick="toggleTheme()" title="Toggle Theme">☀️</button>
                    <div class="profile-dropdown-container">
                        <button class="profile-trigger" onclick="this.nextElementSibling.classList.toggle('show'); event.stopPropagation();">
                            <div class="profile-avatar"><%= currentUser != null ? currentUser.getUserName().substring(0,1).toUpperCase() : "O" %></div>
                            <span class="profile-name"><%= currentUser != null ? currentUser.getUserName().split(" ")[0] : "Owner" %></span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                        </button>
                        <div class="profile-dropdown-menu">
                            <a href="../profile.jsp">Profile</a>
                            <a href="../profile.jsp">Settings</a>
                            <div class="dropdown-divider"></div>
                            <a href="#" onclick="logout(); return false;">Log out</a>
                        </div>
                    </div>
                </div>
            </div>
        </nav>
    </header>

    <div class="owner-layout">
        <aside class="owner-sidebar">
            <h3>Restaurant</h3>
            <% if (myRestaurants != null && !myRestaurants.isEmpty()) { %>
                <form action="dashboard" method="GET" style="padding: 10px 20px;">
                    <select name="switchRestaurantId" onchange="this.form.submit()" style="width: 100%; padding: 8px; border-radius: 6px; background: var(--bg-card); color: var(--text-primary); border: 1px solid var(--border);">
                        <% for (Restaurant r : myRestaurants) { %>
                            <option value="<%= r.getRestaurantID() %>" <%= (myRestaurant != null && myRestaurant.getRestaurantID() == r.getRestaurantID()) ? "selected" : "" %>>
                                <%= r.getName() %>
                            </option>
                        <% } %>
                    </select>
                </form>
            <% } %>
            <a href="dashboard">Dashboard</a>
            <a href="menu">Menu Management</a>
            <a href="orders" class="active">Order History</a>
            <a href="dashboard?action=new" style="margin-top: 20px; color: var(--accent);">+ Add New Restaurant</a>
        </aside>

        <main class="owner-main">
            <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Restaurant Order History</h1>

            <div class="table-card">
                <h2>All Orders</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Customer ID</th>
                            <th>Date & Time</th>
                            <th>Total Amount</th>
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
                                <td colspan="7" style="text-align: center; color: var(--text-muted);">No orders found for this restaurant.</td>
                            </tr>
                        <%
                            } else {
                                for (Order order : orderList) {
                        %>
                                    <tr>
                                        <td>DIVA-<%= order.getOrderID() %></td>
                                        <td><%= order.getUserID() %></td>
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
                                                <select name="status" style="background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.15); color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.85rem;">
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


