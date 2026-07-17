<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Restaurant, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<Restaurant> restaurantList = (List<Restaurant>) request.getAttribute("restaurantList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Restaurants - Admin Dashboard</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css">
</head>
<body>
    <header>
        <nav class="navbar">
            <div class="container">
                <a href="../callRestaurantServlet" class="nav-logo" style="text-decoration: none; display: flex; align-items: center; gap: 8px;">
                    <img src="../images/logo.png" alt="Diva Foods Logo" class="brand-logo-img">
                    <span style="color: var(--text-muted); font-size: 0.85rem; font-weight: 600;">(Admin)</span>
                </a>
                <div class="nav-actions" style="display: flex; align-items: center; gap: 16px;">
                    <span style="color: var(--text-secondary); font-size: 0.95rem;">Hello! <%= currentUser.getUserName() %> <span style="color: red;">&hearts;</span></span>
                    <button class="theme-toggle" onclick="toggleTheme()" aria-label="Toggle theme" style="background: var(--bg-glass); border: 1px solid var(--border); border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; cursor: pointer; color: var(--text-primary);">☀️</button>
                    <a href="../logout" class="btn btn-danger btn-sm" style="padding: 6px 12px; font-size: 0.85rem; border-radius: 6px; text-decoration: none;">Sign Out</a>
                </div>
            </div>
        </nav>
    </header>

    <div class="admin-layout">
        <aside class="admin-sidebar">
            <h3>Management</h3>
            <a href="dashboard">Dashboard</a>
            <a href="users">Manage Users</a>
            <a href="restaurants" class="active">Manage Restaurants</a>
            <a href="orders">Manage Orders</a>
        </aside>

        <main class="admin-main">
            <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Manage Platform Restaurants</h1>

            <div class="table-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h2 style="margin: 0;">All Listed Restaurants</h2>
                    <input type="text" id="restaurantSearch" placeholder="Search by name, cuisine or location..." style="padding: 8px 12px; border-radius: 6px; border: 1px solid var(--border); background: var(--bg-input); color: var(--text-primary); width: 300px; font-size: 0.9rem;" oninput="filterRestaurants()">
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Image</th>
                            <th>Name</th>
                            <th>Cuisine</th>
                            <th>Delivery Time</th>
                            <th>Rating</th>
                            <th>Owner ID</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (restaurantList == null || restaurantList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="9" style="text-align: center; color: var(--text-muted);">No restaurants found.</td>
                            </tr>
                        <%
                            } else {
                                int serialCount = 1;
                                for (Restaurant r : restaurantList) {
                        %>
                                    <tr class="restaurant-row">
                                        <td><%= serialCount++ %></td>
                                        <td>
                                            <img src="../<%= r.getImagePath() %>" alt="<%= r.getName() %>" style="width: 50px; height: 35px; border-radius: 4px; object-fit: cover;">
                                        </td>
                                        <td><strong><%= r.getName() %></strong><br><small style="color: var(--text-muted);"><%= r.getAddress() %></small></td>
                                        <td><%= r.getCuisineType() %></td>
                                        <td><%= r.getDeliveryTime() %> mins</td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 4px; white-space: nowrap;">
                                                <span style="color: #ffc107;">★</span> 
                                                <span><%= String.format(java.util.Locale.US, "%.2f", r.getRating()) %></span>
                                            </div>
                                        </td>
                                        <td><%= r.getAdminUserID() %></td>
                                        <td>
                                            <span class="badge badge-<%= r.isActive() ? "active" : "inactive" %>">
                                                <%= r.isActive() ? "Active" : "Disabled" %>
                                            </span>
                                        </td>
                                        <td>
                                            <div style="display: flex; gap: 8px; align-items: center;">
                                                <!-- Toggle Status Form -->
                                                <form action="restaurants" method="POST" style="margin: 0;">
                                                    <input type="hidden" name="action" value="toggleStatus">
                                                    <input type="hidden" name="restaurantId" value="<%= r.getRestaurantID() %>">
                                                    <button type="submit" class="btn btn-secondary btn-sm action-btn" style="width: 70px; padding: 6px 0; font-size: 0.8rem; text-align: center; border-radius: 6px; transition: transform 0.2s ease;">
                                                        <%= r.isActive() ? "Disable" : "Enable" %>
                                                    </button>
                                                </form>
                                                <!-- Delete Restaurant Button (triggers modal) -->
                                                <button type="button" class="btn btn-danger btn-sm action-btn" onclick="showDeleteModal(<%= r.getRestaurantID() %>)" style="width: 70px; padding: 6px 0; font-size: 0.8rem; text-align: center; border-radius: 6px; transition: transform 0.2s ease;">
                                                    Delete
                                                </button>
                                            </div>
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

    <!-- Custom Delete Confirmation Modal -->
    <div id="deleteModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 1000; align-items: center; justify-content: center;">
        <div style="background: var(--bg-card); padding: 30px; border-radius: 12px; border: 1px solid var(--border); width: 350px; text-align: center; box-shadow: var(--shadow-lg);">
            <div style="font-size: 40px; margin-bottom: 15px;">⚠️</div>
            <h3 style="margin-bottom: 10px; font-family: var(--font-heading);">Confirm Deletion</h3>
            <p style="color: var(--text-secondary); margin-bottom: 25px; font-size: 0.95rem;">Are you sure you want to delete this restaurant? This action cannot be undone.</p>
            <div style="display: flex; gap: 12px; justify-content: center;">
                <button type="button" class="btn btn-secondary" onclick="hideDeleteModal()" style="flex: 1;">Cancel</button>
                <form action="restaurants" method="POST" id="deleteForm" style="flex: 1; margin: 0;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="restaurantId" id="deleteRestaurantId" value="">
                    <button type="submit" class="btn btn-danger" style="width: 100%;">Confirm</button>
                </form>
            </div>
        </div>
    </div>

    <script src="../js/app.js"></script>
    <script>
        // Hover animation for action buttons
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.addEventListener('mouseenter', () => btn.style.transform = 'scale(1.05)');
            btn.addEventListener('mouseleave', () => btn.style.transform = 'scale(1)');
        });

        // Custom Modal Logic
        function showDeleteModal(id) {
            document.getElementById('deleteRestaurantId').value = id;
            const modal = document.getElementById('deleteModal');
            modal.style.display = 'flex';
            // Subtle fade in
            modal.style.opacity = '0';
            setTimeout(() => { modal.style.transition = 'opacity 0.2s'; modal.style.opacity = '1'; }, 10);
        }

        function hideDeleteModal() {
            const modal = document.getElementById('deleteModal');
            modal.style.opacity = '0';
            setTimeout(() => { modal.style.display = 'none'; }, 200);
        }

        // Search Filter Logic
        function filterRestaurants() {
            const input = document.getElementById('restaurantSearch').value.toLowerCase();
            const rows = document.querySelectorAll('table.data-table tbody tr');
            rows.forEach(row => {
                // Skip the 'No restaurants found' row if it exists
                if (row.children.length === 1 && row.children[0].colSpan > 1) return;
                
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(input) ? '' : 'none';
            });
        }
    </script>
</body>
</html>


