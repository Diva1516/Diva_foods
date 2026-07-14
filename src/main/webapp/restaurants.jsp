<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Restaurant, com.food.model.User, com.food.model.Cart" %>
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
    <title>Bangalore Restaurants - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/restaurants.css">
    <script>
        window.DIVA_USER = <%= sessionUser != null ? "{\"name\": \"" + sessionUser.getUserName() + "\", \"role\": \"" + sessionUser.getRole() + "\"}" : "null" %>;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
</head>
<body>
    <header></header>

    <section class="restaurants-hero">
        <div class="restaurants-hero-bg">
            <img src="images/restaurant_3d_bg.png" alt="Delicious Food Collage">
        </div>
        <div class="restaurants-hero-content container">
            <h1>Bangalore Restaurants</h1>
            <p>Select an iconic food brand to view its menu and order.</p>
        </div>
    </section>

    <main class="container" style="margin-top: 40px; margin-bottom: 60px;">

        <!-- Search & Premium Filters -->
        <div class="search-filters-wrapper" style="display: flex; flex-direction: column; gap: 20px; padding: 20px; background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); margin-top: -30px; position: relative; z-index: 10; box-shadow: var(--shadow-lg);">
            
            <form action="search" method="GET" class="search-form" style="display: flex; gap: 12px; align-items: center;">
                <div style="flex: 1; position: relative; display: flex; align-items: center;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--accent); position: absolute; left: 16px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <input type="text" name="query" placeholder="Search for restaurant, cuisine or a dish" required autocomplete="off"
                           style="width: 100%; padding: 16px 16px 16px 48px; border-radius: 12px; border: 2px solid var(--border); background: var(--bg-primary); color: var(--text-primary); font-size: 1.05rem; outline: none; transition: border-color 0.3s, box-shadow 0.3s;"
                           onfocus="this.style.borderColor='var(--accent)'; this.style.boxShadow='0 0 0 4px rgba(255, 107, 53, 0.1)'" onblur="this.style.borderColor='var(--border)'; this.style.boxShadow='none'">
                </div>
                <button type="submit" class="btn btn-primary" style="padding: 16px 32px; font-size: 1.05rem; border-radius: 12px; font-weight: 700; background: linear-gradient(135deg, #FF6B35, #ff4b2b); box-shadow: 0 4px 15px rgba(255, 107, 53, 0.4);">Search</button>
            </form>

            <div class="filters-container" style="display: flex; justify-content: flex-end; width: 100%;">
                <select id="sortFilter" style="padding: 12px 20px; border-radius: 12px; background: var(--bg-primary); border: 1px solid var(--border); color: var(--text-primary); font-size: 1rem; font-weight: 600; outline: none; cursor: pointer; box-shadow: 0 4px 10px rgba(0,0,0,0.1); appearance: none; padding-right: 40px; background-image: url('data:image/svg+xml;utf8,<svg fill=\"%23ff4b2b\" height=\"24\" viewBox=\"0 0 24 24\" width=\"24\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M7 10l5 5 5-5z\"/></svg>'); background-repeat: no-repeat; background-position: right 10px center;">
                    <option value="all">Sort by relevance</option>
                    <option value="rating">Sort by rating: High to Low</option>
                </select>
            </div>
        </div>

        <section class="section" style="padding-top: 32px;">
            <div class="restaurant-grid" id="restaurantsContainer">
                <%
                    List<Restaurant> list = (List<Restaurant>) request.getAttribute("allRestaurants");
                    if (list != null) {
                        for (int i = 0; i < list.size(); i++) {
                            Restaurant restaurant = list.get(i);
                %>
                            <div class="restaurant-card animate-fade-in animate-delay-<%= (i % 6) + 1 %>" onclick="window.location.href='menu?restaurantID=<%= restaurant.getRestaurantID() %>'">
                                <div class="card-image">
                                    <img src="<%= restaurant.getImagePath() %>" alt="<%= restaurant.getName() %>" loading="lazy">
                                    <div class="delivery-badge">🕒 <%= restaurant.getDeliveryTime() %> mins</div>
                                </div>
                                <div class="card-body">
                                    <h2 class="card-title"><%= restaurant.getName() %></h2>
                                    <div class="card-meta">
                                        <span class="cuisine-tag"><%= restaurant.getCuisineType() %></span>
                                        <span class="rating">
                                            <span class="star">★</span> <%= String.format(java.util.Locale.US, "%.2f", restaurant.getRating()) %>
                                        </span>
                                    </div>
                                    <p style="font-size: 0.8rem; color: var(--text-muted); margin-top: 12px; display: flex; align-items: center; gap: 4px;">
                                        📍 <%= restaurant.getAddress() %>
                                    </p>
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

    <!-- Core App JS -->
    <script src="js/app.js"></script>
</body>
</html>
