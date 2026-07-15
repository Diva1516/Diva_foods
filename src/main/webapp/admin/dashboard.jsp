<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Order, com.food.model.User" %>
<%
    // Auth Check
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer totalRestaurants = (Integer) request.getAttribute("totalRestaurants");
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Diva Foods</title>
    <link rel="stylesheet" href="../css/common.css">
    <link rel="stylesheet" href="../css/admin.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            <a href="dashboard" class="active">Dashboard</a>
            <a href="users">Manage Users</a>
            <a href="restaurants">Manage Restaurants</a>
            <a href="orders">Manage Orders</a>
        </aside>

        <main class="admin-main">
            <h1 style="font-family: var(--font-heading); margin-bottom: 32px;">Platform Overview</h1>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="label">Total Customers & Partners</div>
                    <div class="value"><%= totalUsers != null ? totalUsers : 0 %></div>
                </div>
                <div class="stat-card">
                    <div class="label">Total Restaurants</div>
                    <div class="value"><%= totalRestaurants != null ? totalRestaurants : 0 %></div>
                </div>
                <div class="stat-card">
                    <div class="label">Total Orders Placed</div>
                    <div class="value"><%= totalOrders != null ? totalOrders : 0 %></div>
                </div>
                <div class="stat-card">
                    <div class="label">Total Platform Revenue</div>
                    <div class="value" style="color: #28a745;">₹<%= totalRevenue != null ? String.format(java.util.Locale.US, "%.2f", totalRevenue) : "0.00" %></div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px; margin-bottom: 32px;">
                <div class="table-card" style="margin-bottom: 0;">
                    <h2 style="margin-top: 0; margin-bottom: 20px;">Revenue & Orders (Last 7 Days)</h2>
                    <div style="height: 300px; width: 100%; overflow-x: auto; overflow-y: hidden;">
                        <div style="height: 100%; min-width: 1200px;">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="table-card" style="margin-bottom: 0;">
                    <h2 style="margin-top: 0; margin-bottom: 20px;">Top Cuisines</h2>
                    <div style="height: 300px; width: 100%; overflow-y: auto; overflow-x: hidden;">
                        <div style="min-height: 250px; height: 250px;">
                            <canvas id="cuisineChart"></canvas>
                        </div>
                        <div id="custom-legend" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; padding: 10px 20px;"></div>
                    </div>
                </div>
            </div>

            <div class="table-card">
                <h2>Recent Orders</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>User ID</th>
                            <th>Restaurant ID</th>
                            <th>Date</th>
                            <th>Total Amount</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (recentOrders == null || recentOrders.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="6" style="text-align: center; color: var(--text-muted);">No orders found.</td>
                            </tr>
                        <%
                            } else {
                                for (Order order : recentOrders) {
                        %>
                                    <tr>
                                        <td><%= String.format("DF-%04d", order.getOrderID()) %></td>
                                        <td><%= order.getUserID() %></td>
                                        <td><%= order.getRestaurantID() %></td>
                                        <td><%= order.getOrderDate() %></td>
                                        <td>₹<%= String.format(java.util.Locale.US, "%.2f", order.getTotalAmount()) %></td>
                                        <td>
                                            <span class="badge badge-<%= order.getStatus().toLowerCase() %>">
                                                <%= order.getStatus() %>
                                            </span>
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
    <script>
        // Data processing for charts
        // Data processing for charts
        <%
            com.food.DAOimpl.OrderDAOImpl orderDAO = new com.food.DAOimpl.OrderDAOImpl();
            com.food.DAOimpl.RestaurantDAOImpl restDAO = new com.food.DAOimpl.RestaurantDAOImpl();
            com.food.DAOimpl.OrderItemDAOImpl orderItemDAO = new com.food.DAOimpl.OrderItemDAOImpl();
            com.food.DAOimpl.MenuDAOImpl menuDAO = new com.food.DAOimpl.MenuDAOImpl();

            java.util.List<com.food.model.Order> allOrders = orderDAO.getAllOrders();
            java.util.Map<String, Double> restRev = new java.util.HashMap<>();
            if(allOrders != null) {
                for(com.food.model.Order o : allOrders) {
                    com.food.model.Restaurant r = restDAO.getRestaurant(o.getRestaurantID());
                    String rName = (r != null) ? r.getName() : "Unknown Restaurant";
                    restRev.put(rName, restRev.getOrDefault(rName, 0.0) + o.getTotalAmount());
                }
            }

            java.util.List<com.food.model.OrderItem> allItems = orderItemDAO.getAllOrderItems();
            java.util.Map<String, Integer> dishCounts = new java.util.HashMap<>();
            if(allItems != null) {
                for(com.food.model.OrderItem item : allItems) {
                    com.food.model.Menu m = menuDAO.getMenu(item.getMenuID());
                    String mName = (m != null) ? m.getItemName() : "Unknown Dish";
                    dishCounts.put(mName, dishCounts.getOrDefault(mName, 0) + item.getQuantity());
                }
            }
        %>
        
        const labels = [];
        const revData = [];
        <% for(String key : restRev.keySet()) { %>
            labels.push('<%= key %>');
            revData.push(<%= restRev.get(key) %>);
        <% } %>

        const cuiLabels = [];
        const cuiData = [];
        <% for(String key : dishCounts.keySet()) { %>
            cuiLabels.push('<%= key %>');
            cuiData.push(<%= dishCounts.get(key) %>);
        <% } %>

        // If no data, use some fallback so it doesn't break
        if(labels.length === 0) {
            labels.push('No Restaurants Yet');
            revData.push(0);
        }
        if(cuiLabels.length === 0) {
            cuiLabels.push('No Dishes Yet');
            cuiData.push(0);
        }
        // Chart JS Configuration
        function getThemeColors() {
            const t = localStorage.getItem('diva-theme') || 'dark';
            return {
                text: t === 'light' ? '#1a1a2e' : '#ffffff',
                grid: t === 'light' ? 'rgba(0,0,0,0.1)' : 'rgba(255,255,255,0.2)'
            };
        }
        
        let colors = getThemeColors();
        Chart.defaults.color = colors.text;
        Chart.defaults.font.family = 'Inter, sans-serif';

        // Revenue Chart (Bar)
        const revCtx = document.getElementById('revenueChart').getContext('2d');
        const revChart = new Chart(revCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Payment (₹)',
                        data: revData,
                        backgroundColor: '#ff6b35',
                        borderRadius: 4,
                        yAxisID: 'y'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        labels: { color: colors.text }
                    }
                },
                interaction: {
                    mode: 'index',
                    intersect: false,
                },
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        ticks: { color: colors.text },
                        grid: { color: colors.grid }
                    },
                    x: {
                        ticks: { color: colors.text },
                        grid: { display: false }
                    }
                }
            }
        });

        const bgColors = [
            '#ff6b35',
            '#28a745',
            '#007bff',
            '#ffc107',
            '#17a2b8'
        ];

        // Dishes Doughnut Chart
        const cuiCtx = document.getElementById('cuisineChart').getContext('2d');
        const cuiChart = new Chart(cuiCtx, {
            type: 'doughnut',
            data: {
                labels: cuiLabels,
                datasets: [{
                    data: cuiData,
                    backgroundColor: bgColors,
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                cutout: '70%'
            }
        });

        // Generate Custom HTML Legend for perfect grid alignment
        const legendContainer = document.getElementById('custom-legend');
        cuiLabels.forEach((label, index) => {
            const color = bgColors[index % bgColors.length];
            const item = document.createElement('div');
            item.style.display = 'flex';
            item.style.alignItems = 'center';
            item.style.fontSize = '0.9rem';
            item.innerHTML = `<span style="display:inline-block; min-width:14px; height:14px; background-color:${color}; margin-right:10px; border-radius:3px;"></span> <span class="legend-text" style="color: ${colors.text}; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${label}</span>`;
            legendContainer.appendChild(item);
        });

        // Listen for theme toggle events from app.js to instantly update charts
        window.addEventListener('themeToggled', function() {
            let newColors = getThemeColors();
            Chart.defaults.color = newColors.text;
            
            // Update Bar Chart
            if(revChart) {
                revChart.options.plugins.legend.labels.color = newColors.text;
                revChart.options.scales.y.ticks.color = newColors.text;
                revChart.options.scales.x.ticks.color = newColors.text;
                revChart.options.scales.y.grid.color = newColors.grid;
                revChart.update();
            }
            // Update Doughnut Chart
            if(cuiChart) {
                cuiChart.update();
            }
            
            // Update Custom Legend Text Colors
            document.querySelectorAll('.legend-text').forEach(el => {
                el.style.color = newColors.text;
            });
        });
    </script>
</body>
</html>
