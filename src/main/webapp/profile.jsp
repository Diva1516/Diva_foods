<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.food.model.User, com.food.model.Cart, com.food.DAOimpl.DeliveryReviewDAOImpl" %>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?redirect=profile.jsp");
        return;
    }
    Cart cart = (Cart) session.getAttribute("cart");
    int cartCount = 0;
    if (cart != null) {
        cartCount = cart.getItems().values().stream().mapToInt(item -> item.getQuantity()).sum();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/profile.css">
    <script>
        window.DIVA_USER = {
            name: "<%= user != null && user.getUserName() != null ? user.getUserName().replace("\"", "\\\"").replace("\n", "") : "" %>",
            role: "<%= user != null ? user.getRole() : "" %>"
        };
        if (!window.DIVA_USER.name) window.DIVA_USER = null;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
</head>
<body>
    <header></header>

    <main class="container profile-page page-header">
        <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">User Dashboard</h1>

        <%
            String successMessage = (String) request.getAttribute("successMessage");
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (successMessage != null) {
        %>
            <div style="background-color: rgba(75, 255, 75, 0.15); border: 1px solid #4bff4b; color: #4bff4b; padding: 10px 14px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; text-align: center;">
                <%= successMessage %>
            </div>
        <%
            }
            if (errorMessage != null) {
        %>
            <div style="background-color: rgba(255, 75, 75, 0.15); border: 1px solid #ff4b4b; color: #ff4b4b; padding: 10px 14px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; text-align: center;">
                <%= errorMessage %>
            </div>
        <%
            }
        %>

        <div class="profile-layout">
            <div class="profile-sidebar animate-fade-in">
                <div class="profile-sidebar-avatar" id="avatarLetter"><%= user.getUserName() != null && user.getUserName().length() > 0 ? user.getUserName().substring(0, 1).toUpperCase() : "U" %></div>
                <div class="username" id="sidebarUsername"><%= user.getUserName() != null ? user.getUserName() : "User" %></div>
                <div class="email" id="sidebarEmail"><%= user.getEmail() %></div>
                <div class="sidebar-nav">
                    <a href="#" class="active">Account Settings</a>
                    
                    <% if ("customer".equalsIgnoreCase(user.getRole())) { %>
                        <a href="callRestaurantServlet">Browse Restaurants</a>
                        <a href="orderHistory">My Orders</a>
                    <% } else if ("admin".equalsIgnoreCase(user.getRole())) { %>
                        <a href="admin/dashboard">Admin Dashboard</a>
                    <% } else if ("restaurant_owner".equalsIgnoreCase(user.getRole())) { %>
                        <a href="restaurant-owner/dashboard">Restaurant Dashboard</a>
                    <% } else if ("delivery".equalsIgnoreCase(user.getRole())) { %>
                        <a href="delivery/dashboard">Delivery Dashboard</a>
                    <% } %>
                    
                    <a href="#" onclick="handleLogout()">Sign Out</a>
                </div>
            </div>

            <div class="profile-main animate-fade-in animate-delay-1">
                <% if ("delivery".equalsIgnoreCase(user.getRole())) { 
                       DeliveryReviewDAOImpl reviewDAO = new DeliveryReviewDAOImpl();
                       double avgRating = reviewDAO.getAverageRating(user.getUserID());
                %>
                <div style="background: linear-gradient(135deg, rgba(255,107,53,0.1), rgba(224,83,26,0.15)); border: 1px solid var(--accent); padding: 20px; border-radius: 12px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <h3 style="color: var(--accent); margin-bottom: 5px;">Your Delivery Stats</h3>
                        <p style="color: var(--text-secondary); font-size: 0.9rem;">Keep up the great work!</p>
                    </div>
                    <div style="display: flex; gap: 30px; text-align: center;">
                        <div>
                            <div style="font-size: 0.85rem; color: var(--text-secondary); text-transform: uppercase;">Total Earnings</div>
                            <div style="font-size: 1.8rem; font-weight: 700; color: white;">₹<%= String.format(java.util.Locale.US, "%.2f", user.getTotalEarnings()) %></div>
                        </div>
                        <div>
                            <div style="font-size: 0.85rem; color: var(--text-secondary); text-transform: uppercase;">Avg Rating</div>
                            <div style="font-size: 1.8rem; font-weight: 700; color: #ffc107;">
                                <%= avgRating > 0 ? String.format(java.util.Locale.US, "%.1f", avgRating) + " ★" : "N/A" %>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <h2>Account Settings</h2>
                <form id="profileForm" action="profileServlet" method="POST">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="profileUsername">Username</label>
                            <input type="text" id="profileUsername" name="username" value="<%= user.getUserName() %>" required>
                        </div>
                        <div class="form-group">
                            <label for="profileEmail">Email Address</label>
                            <input type="email" id="profileEmail" name="email" value="<%= user.getEmail() %>" required readonly style="background-color: rgba(255,255,255,0.05); cursor: not-allowed;">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="profilePhone">Phone Number</label>
                            <input type="tel" id="profilePhone" name="phoneNumber" value="<%= user.getPhoneNumber() != null ? user.getPhoneNumber() : "" %>" placeholder="Enter your phone number">
                        </div>
                    </div>
                    <% if ("customer".equalsIgnoreCase(user.getRole())) { %>
                    <div class="form-group">
                        <label for="profileAddress">Delivery Address</label>
                        <textarea id="profileAddress" name="address" rows="3" required><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                    </div>
                    <% } %>
                    
                    <h3 style="margin-top: 24px; margin-bottom: 16px; font-family: var(--font-heading); color: var(--text-primary); border-top: 1px solid var(--border); padding-top: 24px;">Change Password</h3>
                    <p style="font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 16px;">Leave blank if you do not wish to change your password.</p>
                    <div class="form-row">
                        <div class="form-group" style="position: relative;">
                            <label for="newPassword">New Password</label>
                            <input type="password" id="newPassword" name="newPassword" placeholder="Enter new password">
                        </div>
                        <div class="form-group" style="position: relative;">
                            <label for="confirmPassword">Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary" style="margin-top: 16px;">Save Changes</button>
                </form>

                <!-- Delete User functionality (Requested in requirements) -->
                <div style="margin-top: 40px; text-align: left; padding-top: 20px; border-top: 1px solid var(--border);">
                    <form id="deleteForm" action="deleteUser" method="POST" onsubmit="return confirmDelete()">
                        <button type="submit" style="background: none; border: none; color: #ff4b4b; cursor: pointer; font-size: 0.95rem; font-family: inherit; text-decoration: underline; padding: 0; outline: none;">Delete my account</button>
                    </form>
                </div>
            </div>
        </div>
    </main>

    <footer></footer>

    <script src="js/app.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Are you absolutely sure you want to delete your Diva Foods account? This action cannot be undone.");
        }
        
        function handleLogout() {
            if (confirm("Are you sure you want to sign out?")) {
                // Clear front-end cart too
                clearCart();
                // Redirect to logout function in app.js
                logout();
            }
        }
    </script>
</body>
</html>
