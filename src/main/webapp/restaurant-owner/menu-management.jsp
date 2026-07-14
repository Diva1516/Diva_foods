<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Menu, com.food.model.Restaurant, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Restaurant myRestaurant = (Restaurant) session.getAttribute("myRestaurant");
    List<Menu> menuList = (List<Menu>) request.getAttribute("menuList");
    List<Restaurant> myRestaurants = (List<Restaurant>) request.getAttribute("myRestaurants"); // Ensure MenuManagementServlet sets this!
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Menu - Restaurant Dashboard</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css"> <!-- Reuse table and header layouts -->
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
            <a href="menu" class="active">Menu Management</a>
            <a href="orders">Order History</a>
            <a href="dashboard?action=new" style="margin-top: 20px; color: var(--accent);">+ Add New Restaurant</a>
        </aside>

        <main class="owner-main">
            <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Manage Menu Items</h1>

            <!-- Add Menu Item Form Card -->
            <div class="menu-form-card">
                <h2>Add New Dish</h2>
                <form action="menu" method="POST" style="display: flex; flex-direction: column; gap: 16px; max-width: 600px;">
                    <input type="hidden" name="action" value="add">
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group" style="margin: 0;">
                            <label for="dishName">Dish Name</label>
                            <input type="text" id="dishName" name="name" placeholder="e.g. Special Veg Biryani" required style="width: 100%;">
                        </div>
                        <div class="form-group" style="margin: 0;">
                            <label for="price">Price (₹)</label>
                            <input type="number" step="0.01" id="price" name="price" placeholder="e.g. 249.00" required style="width: 100%;">
                        </div>
                    </div>

                    <div class="form-group" style="margin: 0;">
                        <label for="description">Description</label>
                        <input type="text" id="description" name="description" placeholder="Briefly describe the ingredients or taste" required style="width: 100%;">
                    </div>

                    <div class="form-group" style="margin: 0;">
                        <label for="imagePath">Dish Image Source (Relative URL)</label>
                        <select id="imagePath" name="imagePath" style="background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.15); color: white; padding: 10px; border-radius: 8px; width: 100%;">
                            <option value="images/biryani.png">Biryani</option>
                            <option value="images/dosa.png">Masala Dosa</option>
                            <option value="images/idli.png">Idli Sambar</option>
                            <option value="images/vada.png">Medu Vada</option>
                            <option value="images/chicken_65.png">Chicken 65</option>
                            <option value="images/filter_coffee.png">Filter Coffee</option>
                            <option value="images/corner_house.png">Ice Cream / Dessert</option>
                            <option value="images/truffles.png">Burger / Continental</option>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-primary" style="align-self: flex-start;">Add Dish to Menu</button>
                </form>
            </div>

            <!-- Menu List Table Card -->
            <div class="table-card">
                <h2>Current Menu Items</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Dish ID</th>
                            <th>Image</th>
                            <th>Dish Name</th>
                            <th>Description</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (menuList == null || menuList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-muted);">No dishes added to menu yet.</td>
                            </tr>
                        <%
                            } else {
                                for (Menu item : menuList) {
                        %>
                                    <tr>
                                        <td><%= item.getMenuID() %></td>
                                        <td>
                                            <img src="../<%= item.getImagePath() %>" alt="<%= item.getItemName() %>" style="width: 45px; height: 45px; border-radius: 4px; object-fit: cover;">
                                        </td>
                                        <td><strong><%= item.getItemName() %></strong></td>
                                        <td><%= item.getDescription() %></td>
                                        <td style="color: var(--accent); font-weight: 600;">₹<%= String.format(java.util.Locale.US, "%.2f", item.getPrice()) %></td>
                                        <td>
                                            <span class="badge badge-<%= item.isAvailable() ? "active" : "inactive" %>">
                                                <%= item.isAvailable() ? "Available" : "Sold Out" %>
                                            </span>
                                        </td>
                                        <td>
                                            <!-- Delete Dish Form -->
                                            <form action="menu" method="POST" style="margin: 0; display: inline;" onsubmit="return confirm('Are you sure you want to remove this dish?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="menuId" value="<%= item.getMenuID() %>">
                                                <button type="submit" class="btn btn-danger btn-sm" style="padding: 4px 8px; font-size: 0.8rem;">Remove</button>
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
