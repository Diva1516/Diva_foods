<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    List<User> userList = (List<User>) request.getAttribute("userList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Admin Dashboard</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css">
    <style>
        .tabs-container {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 12px;
        }
        .tab-btn {
            background: var(--bg-glass);
            border: 1px solid var(--border);
            color: var(--text-secondary);
            padding: 8px 16px;
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition-fast);
        }
        .tab-btn:hover {
            border-color: var(--accent);
            color: var(--text-primary);
        }
        .tab-btn.active {
            background: var(--accent-gradient);
            color: var(--text-primary);
            border-color: transparent;
            box-shadow: 0 4px 10px var(--accent-glow);
        }
        
        select option {
            background-color: var(--bg-card);
            color: var(--text-primary);
        }
        .brand-logo-img {
            height: 40px; 
            width: auto; 
            border-radius: 8px; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
    <header>
        <nav class="navbar">
            <div class="container">
                <a href="dashboard" class="nav-brand">
                    <img src="../images/logo.png" alt="Diva Foods Logo" class="brand-logo-img">
                    <span class="brand-text">Diva <span>Foods</span></span>
                </a>
                <div class="nav-actions">
                    <span class="user-greeting">Hello! <%= currentUser.getUserName() %> <span style="color: red;">&hearts;</span></span>
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
            <a href="users" class="active">Manage Users</a>
            <a href="restaurants">Manage Restaurants</a>
            <a href="orders">Manage Orders</a>
        </aside>

        <main class="admin-main">
            <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Manage Platform Users</h1>

            <div class="tabs-container">
                <button class="tab-btn active" id="tab-all" onclick="filterUsers('all')">All (<span id="cnt-all">0</span>)</button>
                <button class="tab-btn" id="tab-customer" onclick="filterUsers('customer')">Customers (<span id="cnt-customer">0</span>)</button>
                <button class="tab-btn" id="tab-restaurant_owner" onclick="filterUsers('restaurant_owner')">Restaurant Owners (<span id="cnt-restaurant_owner">0</span>)</button>
                <button class="tab-btn" id="tab-delivery_agent" onclick="filterUsers('delivery_agent')">Delivery Agents (<span id="cnt-delivery_agent">0</span>)</button>
                <button class="tab-btn" id="tab-admin" onclick="filterUsers('admin')">Admins (<span id="cnt-admin">0</span>)</button>
            </div>

            <div class="table-card">
                <h2>All Registered Users</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Username</th>
                            <th>Email Address</th>
                            <th>Address</th>
                            <th>Current Role</th>
                            <th>Update Role</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (userList == null || userList.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--text-muted);">No users found.</td>
                            </tr>
                        <%
                            } else {
                                for (User u : userList) {
                        %>
                                    <tr class="user-row" data-role="<%= u.getRole().toLowerCase() %>">
                                        <td><%= u.getUserID() %></td>
                                        <td><%= u.getUserName() %></td>
                                        <td><%= u.getEmail() %></td>
                                        <td><%= (u.getAddress() != null && !u.getAddress().trim().isEmpty()) ? u.getAddress() : "<span style='color: var(--text-muted); font-style: italic;'>No delivery address</span>" %></td>
                                        <td>
                                            <span class="badge badge-<%= u.getRole().toLowerCase() %>">
                                                <%= u.getRole() %>
                                            </span>
                                        </td>
                                        <td>
                                            <!-- Update Role Form -->
                                            <form action="users" method="POST" style="display: flex; gap: 8px; align-items: center; margin: 0;">
                                                <input type="hidden" name="action" value="updateRole">
                                                <input type="hidden" name="userId" value="<%= u.getUserID() %>">
                                                <select name="role" style="background: var(--bg-card, #1a1a1a); border: 1px solid var(--border); color: var(--text-primary); padding: 4px 8px; border-radius: 4px; font-size: 0.85rem;">
                                                    <option value="customer" <%= "customer".equalsIgnoreCase(u.getRole()) ? "selected" : "" %>>Customer</option>
                                                    <option value="restaurant_owner" <%= "restaurant_owner".equalsIgnoreCase(u.getRole()) ? "selected" : "" %>>Restaurant Owner</option>
                                                    <option value="delivery_agent" <%= "delivery_agent".equalsIgnoreCase(u.getRole()) ? "selected" : "" %>>Delivery Agent</option>
                                                    <option value="admin" <%= "admin".equalsIgnoreCase(u.getRole()) ? "selected" : "" %>>System Admin</option>
                                                </select>
                                                <button type="submit" class="btn btn-primary btn-sm" style="padding: 4px 8px; font-size: 0.8rem;">Change</button>
                                            </form>
                                        </td>
                                        <td>
                                            <!-- Delete User Form -->
                                            <% if (u.getUserID() != currentUser.getUserID()) { %>
                                                <form action="users" method="POST" onsubmit="return confirm('Are you sure you want to delete this user?')" style="display: inline; margin: 0;">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="userId" value="<%= u.getUserID() %>">
                                                    <button type="submit" class="btn btn-danger btn-sm" style="padding: 4px 8px; font-size: 0.8rem;">Delete</button>
                                                </form>
                                            <% } else { %>
                                                <span style="color: var(--text-muted); font-size: 0.8rem;">Current Session</span>
                                            <% } %>
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

    <script>
        function filterUsers(role) {
            // Update active class on tab buttons
            document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
            document.getElementById('tab-' + role).classList.add('active');

            // Show/hide rows
            document.querySelectorAll('.user-row').forEach(row => {
                if (role === 'all' || row.getAttribute('data-role') === role) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        document.addEventListener('DOMContentLoaded', () => {
            // Compute counts
            const rows = document.querySelectorAll('.user-row');
            let counts = { all: 0, customer: 0, restaurant_owner: 0, delivery_agent: 0, admin: 0 };
            
            rows.forEach(row => {
                const r = row.getAttribute('data-role');
                counts.all++;
                if (counts[r] !== undefined) {
                    counts[r]++;
                }
            });

            // Set text content
            document.getElementById('cnt-all').textContent = counts.all;
            document.getElementById('cnt-customer').textContent = counts.customer;
            document.getElementById('cnt-restaurant_owner').textContent = counts.restaurant_owner;
            document.getElementById('cnt-delivery_agent').textContent = counts.delivery_agent;
            document.getElementById('cnt-admin').textContent = counts.admin;
        });
    </script>
    <script src="../js/app.js"></script>
</body>
</html>


