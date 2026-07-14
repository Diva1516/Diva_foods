<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Restaurant, com.food.model.Menu, com.food.model.User, com.food.model.Cart" %>
<%
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
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restaurant Menu - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/menu.css">
    <script>
        window.DIVA_USER = <%= sessionUser != null ? "{\"name\": \"" + sessionUser.getUserName() + "\", \"role\": \"" + sessionUser.getRole() + "\"}" : "null" %>;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
</head>
<body>
    <header></header>

    <main class="container page-header">
        <a href="callRestaurantServlet" class="back-link">← Back to Restaurants</a>
        
        <div id="restaurantHeader" class="menu-header animate-fade-in">
            <%
                Restaurant restaurant = (Restaurant) request.getAttribute("restaurant");
                if (restaurant != null) {
            %>
                    <img src="<%= restaurant.getImagePath() %>" alt="<%= restaurant.getName() %>" class="restaurant-img">
                    <div class="restaurant-info">
                        <h1><%= restaurant.getName() %></h1>
                        <div class="meta">
                            <span>🍲 <%= restaurant.getCuisineType() %></span>
                            <span>⭐ <%= String.format(java.util.Locale.US, "%.2f", restaurant.getRating()) %> Rating</span>
                            <span>🕒 <%= restaurant.getDeliveryTime() %> Mins Delivery</span>
                            <span>📍 <%= restaurant.getAddress() %></span>
                        </div>
                    </div>
            <%
                }
            %>
        </div>

        <section class="section" style="padding-top: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
                <h2 style="font-family: var(--font-heading); font-size: 1.4rem; margin: 0;">Popular Dishes</h2>
                <select id="menuSortFilter" style="padding: 10px 16px; border-radius: 8px; background: var(--bg-primary); border: 1px solid var(--border); color: var(--text-primary); font-size: 0.95rem; font-weight: 600; outline: none; cursor: pointer; box-shadow: var(--shadow-sm); appearance: none; padding-right: 32px; background-image: url('data:image/svg+xml;utf8,<svg fill=\"%23ff4b2b\" height=\"20\" viewBox=\"0 0 24 24\" width=\"20\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M7 10l5 5 5-5z\"/></svg>'); background-repeat: no-repeat; background-position: right 8px center;">
                    <option value="all">Sort by relevance</option>
                    <option value="price_low">Price: Low to High</option>
                    <option value="price_high">Price: High to Low</option>
                </select>
            </div>
            <div class="menu-grid" id="menuContainer">
                <%
                    List<Menu> menuItems = (List<Menu>) request.getAttribute("menuList");
                    if (menuItems != null && restaurant != null) {
                        for (int i = 0; i < menuItems.size(); i++) {
                            Menu item = menuItems.get(i);
                %>
                            <div class="menu-item animate-fade-in animate-delay-<%= (i % 5) + 1 %>">
                                <img src="<%= item.getImagePath() %>" alt="<%= item.getItemName() %>" class="item-image" loading="lazy">
                                <div class="item-info">
                                    <div>
                                        <h3 class="item-name"><%= item.getItemName() %></h3>
                                        <p class="item-desc"><%= item.getDescription() %></p>
                                    </div>
                                    <div class="item-footer">
                                        <span class="item-price">₹<%= String.format(java.util.Locale.US, "%.2f", item.getPrice()) %></span>
                                        <%
                                            boolean isCustomer = (sessionUser == null || "customer".equalsIgnoreCase(sessionUser.getRole()));
                                            if (isCustomer) {
                                        %>
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
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                <%
                        }
                    }
                %>
            </div>
        </section>
    </main>

    <footer></footer>
    <script src="js/app.js"></script>
</body>
</html>
