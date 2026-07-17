<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Order, com.food.model.Restaurant, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Restaurant myRestaurant = (Restaurant) session.getAttribute("myRestaurant");
    
    Integer pendingOrdersCount = (Integer) request.getAttribute("pendingOrdersCount");
    Integer totalOrdersCount = (Integer) request.getAttribute("totalOrdersCount");
    Double revenue = (Double) request.getAttribute("revenue");
    List<Order> activeOrders = (List<Order>) request.getAttribute("activeOrders");
    List<Restaurant> myRestaurants = (List<Restaurant>) request.getAttribute("myRestaurants");
    
    String actionParam = request.getParameter("action");
    boolean showAddForm = "new".equals(actionParam) || myRestaurant == null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restaurant Dashboard - Diva Foods</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css"> <!-- Reuse dashboard layout and metrics styles -->
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
                    <a href="dashboard" class="active">Owner Dashboard</a>
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
            <a href="dashboard" class="active">Dashboard</a>
            <a href="menu">Menu Management</a>
            <a href="orders">Order History</a>
            <a href="dashboard?action=new" style="margin-top: 20px; color: var(--accent);">+ Add New Restaurant</a>
        </aside>

        <main class="owner-main">
            <% if (showAddForm) { %>
                <div class="cart-empty" style="text-align: center; padding: 40px 20px;">
                    <h2><%= myRestaurants != null && !myRestaurants.isEmpty() ? "Add Another Restaurant" : "Welcome to Diva Foods Partner Network!" %></h2>
                    <p>Register your restaurant below to start receiving orders.</p>
                    <form action="dashboard" method="POST" style="max-width: 500px; margin: 30px auto; text-align: left; background: var(--bg-card); padding: 30px; border-radius: 12px; border: 1px solid var(--border);">
                        <input type="hidden" name="action" value="registerRestaurant">
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="display: block; margin-bottom: 8px; font-weight: 500; color: var(--text-secondary);">Restaurant Name</label>
                            <input type="text" name="name" required style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--border); background: rgba(0,0,0,0.2); color: #fff; font-size: 1rem;">
                        </div>
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="display: block; margin-bottom: 8px; font-weight: 500; color: var(--text-secondary);">Cuisine Type (e.g. Indian, Chinese)</label>
                            <input type="text" name="cuisineType" required style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--border); background: rgba(0,0,0,0.2); color: #fff; font-size: 1rem;">
                        </div>
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label style="display: block; margin-bottom: 8px; font-weight: 500; color: var(--text-secondary);">Average Delivery Time (minutes)</label>
                            <input type="number" name="deliveryTime" required value="30" style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--border); background: rgba(0,0,0,0.2); color: #fff; font-size: 1rem;">
                        </div>
                        <div class="form-group" style="margin-bottom: 24px;">
                            <label style="display: block; margin-bottom: 8px; font-weight: 500; color: var(--text-secondary);">Complete Address</label>
                            <textarea name="address" required rows="3" style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--border); background: rgba(0,0,0,0.2); color: #fff; font-size: 1rem; resize: vertical;"></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary" style="width: 100%; padding: 14px; font-size: 1.1rem; border-radius: 8px;">Register Restaurant</button>
                    </form>
                </div>
            <% } else { %>
                <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Restaurant Overview</h1>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="label">Pending Orders</div>
                        <div class="value"><%= pendingOrdersCount != null ? pendingOrdersCount : 0 %></div>
                    </div>
                    <div class="stat-card">
                        <div class="label">Total Orders</div>
                        <div class="value"><%= totalOrdersCount != null ? totalOrdersCount : 0 %></div>
                    </div>
                    <div class="stat-card">
                        <div class="label">Total Restaurant Earnings</div>
                        <div class="value" style="color: #28a745;">₹<%= revenue != null ? String.format(java.util.Locale.US, "%.2f", revenue) : "0.00" %></div>
                    </div>
                </div>

                <div class="table-card" style="margin-top: 32px;">
                    <h2>Active Orders (Needs Action)</h2>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Customer ID</th>
                                <th>Date & Time</th>
                                <th>Total Amount</th>
                                <th>Payment</th>
                                <th>Current Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (activeOrders == null || activeOrders.isEmpty()) {
                            %>
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted);">No active orders at the moment.</td>
                                </tr>
                            <%
                                } else {
                                    for (Order order : activeOrders) {
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
                                                <!-- Action Buttons to advance order status -->
                                                <form action="orders" method="POST" style="margin: 0; display: inline;">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                                    
                                                    <% if ("Pending".equalsIgnoreCase(order.getStatus())) { %>
                                                        <input type="hidden" name="status" value="Preparing">
                                                        <button type="submit" class="btn btn-primary btn-sm" style="padding: 4px 8px; font-size: 0.8rem;">Accept & Prepare</button>
                                                    <% } else if ("Preparing".equalsIgnoreCase(order.getStatus())) { %>
                                                        <input type="hidden" name="status" value="Ready">
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="padding: 4px 8px; font-size: 0.8rem; background-color: #007bff; border-color: #007bff;">Mark as Ready</button>
                                                    <% } else if ("Ready".equalsIgnoreCase(order.getStatus())) { %>
                                                        <input type="hidden" name="status" value="Delivered">
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="padding: 4px 8px; font-size: 0.8rem; background-color: #28a745; border-color: #28a745;">Deliver Order</button>
                                                    <% } %>
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
            <% } %>
        </main>
    </div>

    <footer></footer>
    <script src="../js/app.js"></script>
    <!-- Note: initTheme, injectNavigation etc are auto-called by DOMContentLoaded in app.js -->
</body>
</html>


