<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Restaurant, com.food.model.Menu, com.food.DAOimpl.RestaurantDAOImpl, com.food.model.User, com.food.model.Cart" %>
<%
    String query = (String) request.getAttribute("query");
    List<Restaurant> matchingRestaurants = (List<Restaurant>) request.getAttribute("matchingRestaurants");
    List<Menu> matchingMenus = (List<Menu>) request.getAttribute("matchingMenus");
    RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
    
    User sessionUser = (User) session.getAttribute("user");
    Cart sessionCart = (Cart) session.getAttribute("cart");
    int cartCount = 0;
    if (sessionCart != null) {
        cartCount = sessionCart.getItems().values().stream().mapToInt(item -> item.getQuantity()).sum();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Results for "<%= query %>" - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/restaurants.css">
    <link rel="stylesheet" href="css/menu.css">
    <script>
        window.DIVA_USER = <%= sessionUser != null ? "{\"name\": \"" + sessionUser.getUserName() + "\", \"role\": \"" + sessionUser.getRole() + "\"}" : "null" %>;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
    <style>
        .search-results-page {
            padding-top: calc(var(--nav-height) + 40px);
        }
        .search-header {
            margin-bottom: 40px;
        }
        .results-section {
            margin-bottom: 48px;
        }
        .results-section h2 {
            font-family: var(--font-heading);
            font-size: 1.4rem;
            margin-bottom: 24px;
            border-left: 4px solid var(--accent);
            padding-left: 12px;
        }
        .no-results {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 40px;
            text-align: center;
            margin-bottom: 40px;
        }
        .dish-restaurant-name {
            font-size: 0.8rem;
            color: var(--accent);
            font-weight: 600;
            margin-top: 4px;
            display: inline-block;
        }
    </style>
</head>
<body>
    <header></header>

    <main class="container search-results-page">
        <a href="callRestaurantServlet" class="back-link">← Back to Restaurants</a>

        <div class="search-header">
            <h1>Search Results</h1>
            <p style="color: var(--text-secondary); margin-top: 4px;">Showing results matching "<span style="color: white; font-weight: 600;"><%= query %></span>"</p>

            <div class="search-container animate-fade-in" style="margin-top: 24px; max-width: 600px;">
                <form action="search" method="GET" class="search-form" style="display: flex; gap: 12px;">
                    <input type="text" name="query" value="<%= query %>" placeholder="Search for restaurants, cuisines or dishes..." required 
                           style="flex: 1; padding: 14px 20px; border-radius: 12px; border: 1px solid rgba(255, 255, 255, 0.1); background: rgba(255, 255, 255, 0.05); color: white; font-size: 1rem; outline: none; transition: border-color 0.2s;"
                           onfocus="this.style.borderColor='var(--accent)'" onblur="this.style.borderColor='rgba(255, 255, 255, 0.1)'">
                    <button type="submit" class="btn btn-primary" style="padding: 0 28px;">Search</button>
                </form>
            </div>
        </div>

        <%
            boolean hasRestaurants = (matchingRestaurants != null && !matchingRestaurants.isEmpty());
            boolean hasMenus = (matchingMenus != null && !matchingMenus.isEmpty());

            if (!hasRestaurants && !hasMenus) {
        %>
            <div class="no-results animate-fade-in">
                <div style="font-size: 3rem; margin-bottom: 16px;">🔍</div>
                <h2>No Results Found</h2>
                <p style="color: var(--text-secondary); margin-bottom: 24px;">We couldn't find any restaurants or dishes matching your search query. Try searching for something else!</p>
                <a href="callRestaurantServlet" class="btn btn-primary">Discover Top Cuisines</a>
            </div>
        <%
            } else {
        %>
            <!-- Restaurants Section -->
            <% if (hasRestaurants) { %>
                <div class="results-section animate-fade-in">
                    <h2>Matching Restaurants (<%= matchingRestaurants.size() %>)</h2>
                    <div class="restaurant-grid">
                        <%
                            for (int i = 0; i < matchingRestaurants.size(); i++) {
                                Restaurant restaurant = matchingRestaurants.get(i);
                        %>
                                <div class="restaurant-card" onclick="window.location.href='menu?restaurantID=<%= restaurant.getRestaurantID() %>'">
                                    <div class="card-image">
                                        <img src="<%= restaurant.getImagePath() %>" alt="<%= restaurant.getName() %>" loading="lazy">
                                        <div class="delivery-badge">🕒 <%= restaurant.getDeliveryTime() %> mins</div>
                                    </div>
                                    <div class="card-body">
                                        <h3 class="card-title" style="margin-bottom: 6px;"><%= restaurant.getName() %></h3>
                                        <div class="card-meta">
                                            <span class="cuisine-tag"><%= restaurant.getCuisineType() %></span>
                                            <span class="rating">
                                                <span class="star">★</span> <%= String.format(java.util.Locale.US, "%.2f", restaurant.getRating()) %>
                                            </span>
                                        </div>
                                        <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 12px;">
                                            📍 <%= restaurant.getAddress() %>
                                        </p>
                                    </div>
                                </div>
                        <%
                            }
                        %>
                    </div>
                </div>
            <% } %>

            <!-- Dishes Section -->
            <% if (hasMenus) { %>
                <div class="results-section animate-fade-in" style="margin-top: 40px;">
                    <h2>Matching Dishes (<%= matchingMenus.size() %>)</h2>
                    <div class="menu-grid">
                        <%
                            for (int i = 0; i < matchingMenus.size(); i++) {
                                Menu item = matchingMenus.get(i);
                                Restaurant rest = restaurantDAO.getRestaurant(item.getRestaurantID());
                                String restName = (rest != null) ? rest.getName() : "Restaurant";
                        %>
                                <div class="menu-item">
                                    <img src="<%= item.getImagePath() %>" alt="<%= item.getItemName() %>" class="item-image" loading="lazy">
                                    <div class="item-info">
                                        <div>
                                            <h3 class="item-name" style="margin-bottom: 2px;"><%= item.getItemName() %></h3>
                                            <p class="item-desc"><%= item.getDescription() %></p>
                                            <a href="menu?restaurantID=<%= item.getRestaurantID() %>" class="dish-restaurant-name">🏪 <%= restName %></a>
                                        </div>
                                        <div class="item-footer">
                                            <span class="item-price">₹<%= String.format(java.util.Locale.US, "%.2f", item.getPrice()) %></span>
                                            <div class="cart-action-container" id="cart-action-<%= item.getMenuID() %>">
                                        <%
                                            if (sessionCart != null && sessionCart.getItems().containsKey(item.getMenuID())) {
                                                int qty = sessionCart.getItems().get(item.getMenuID()).getQuantity();
                                        %>
                                            <div class="inline-qty-control">
                                                <button type="button" class="qty-btn" onclick="updateQtyAjax(<%= item.getMenuID() %>, <%= item.getRestaurantID() %>, <%= qty - 1 %>)">−</button>
                                                <span class="qty-value"><%= qty %></span>
                                                <button type="button" class="qty-btn" onclick="updateQtyAjax(<%= item.getMenuID() %>, <%= item.getRestaurantID() %>, <%= qty + 1 %>)">+</button>
                                            </div>
                                        <%
                                            } else {
                                        %>
                                            <button type="button" class="add-to-cart-btn"
                                                onclick="handleAddToCartAjax(<%= item.getMenuID() %>, <%= item.getRestaurantID() %>, this)">
                                                Add to Cart
                                            </button>
                                        <%
                                            }
                                        %>
                                        </div>
                                    </div>
                                </div>
                        <%
                            }
                        %>
                    </div>
                </div>
            <% } %>
        <%
            }
        %>
    </main>

    <footer></footer>

    <script src="js/app.js"></script>
</body>
</html>


