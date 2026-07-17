<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.food.model.Cart, com.food.model.CartItem, com.food.model.User" %>
<%
    Cart cart = (Cart) session.getAttribute("cart");
    User user = (User) session.getAttribute("user");
    int cartCount = 0;
    if (cart != null) {
        cartCount = cart.getItems().values().stream().mapToInt(item -> item.getQuantity()).sum();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Cart - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/cart.css">
    <script>
        window.DIVA_USER = {
            name: "<%= user != null ? user.getUserName().replace("\"", "\\\"").replace("\n", "") : "" %>",
            role: "<%= user != null ? user.getRole() : "" %>"
        };
        if (!window.DIVA_USER.name) window.DIVA_USER = null;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
</head>
<body>
    <header></header>

    <main class="container cart-page page-header">
        <h1 style="font-family: var(--font-heading); margin-bottom: 24px;">Your Shopping Cart</h1>

        <div id="cartContent">
            <%
                if (cart == null || cart.isEmpty()) {
            %>
                <div class="cart-empty animate-fade-in">
                    <div class="empty-icon" style="color: var(--accent);">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path><line x1="3" y1="6" x2="21" y2="6"></line><path d="M16 10a4 4 0 0 1-8 0"></path></svg>
                    </div>
                    <h2>Your Cart is Empty</h2>
                    <p>You haven't added any items to your cart yet. Browse our top kitchens to order!</p>
                    <a href="callRestaurantServlet" class="btn btn-primary">Discover Restaurants</a>
                </div>
            <%
                } else {
                    double subtotal = cart.getTotalPrice();
                    double deliveryFee = 40.00;
                    double gst = subtotal * 0.05;
                    double total = subtotal + deliveryFee + gst;
            %>
                <div class="cart-layout">
                    <div class="cart-items" id="cartItemsContainer">
                        <%
                            int index = 0;
                            java.util.Iterator<CartItem> it = cart.getItems().values().iterator();
                            while (it.hasNext()) {
                                CartItem item = it.next();
                                index++;
                        %>
                            <div class="cart-item animate-fade-in" id="cart-item-<%= item.getMenuId() %>">
                                <img src="<%= item.getImagePath() != null ? item.getImagePath() : "images/biryani.png" %>" alt="<%= item.getName() %>" class="item-image">
                                <div class="item-details">
                                    <h3 class="item-name"><%= item.getName() %></h3>
                                    <div class="item-controls">
                                        <div class="quantity-control">
                                            <button type="button" class="qty-btn" onclick="updateQty(<%= item.getMenuId() %>, <%= item.getQuantity() - 1 %>, <%= item.getRestaurantId() %>)">−</button>
                                            <div class="qty-value" id="qty-<%= item.getMenuId() %>"><%= item.getQuantity() %></div>
                                            <button type="button" class="qty-btn" onclick="updateQty(<%= item.getMenuId() %>, <%= item.getQuantity() + 1 %>, <%= item.getRestaurantId() %>)">+</button>
                                        </div>
                                        <span class="item-total" id="total-<%= item.getMenuId() %>">₹<%= String.format(java.util.Locale.US, "%.2f", item.getTotalPrice()) %></span>
                                        <button type="button" class="remove-btn" onclick="removeItem(<%= item.getMenuId() %>, <%= item.getRestaurantId() %>)">Remove</button>
                                    </div>
                                </div>
                            </div>
                        <%
                            }
                            Integer sessionRestId = (Integer) session.getAttribute("restaurantId");
                            if (sessionRestId == null && cart != null && !cart.isEmpty()) {
                                // Fallback: Get it directly from the first cart item
                                sessionRestId = cart.getItems().values().iterator().next().getRestaurantId();
                            }
                            
                            if (sessionRestId != null) {
                        %>
                            <div style="margin-top: 20px; padding: 16px; text-align: center; border: 1px dashed var(--accent); border-radius: 12px; background: rgba(255, 107, 53, 0.05); transition: background 0.3s;" onmouseover="this.style.background='rgba(255, 107, 53, 0.1)'" onmouseout="this.style.background='rgba(255, 107, 53, 0.05)'">
                                <a href="menu?restaurantID=<%= sessionRestId %>" style="color: var(--accent); font-weight: 700; text-decoration: none; font-size: 1.05rem; display: flex; align-items: center; justify-content: center; gap: 8px;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                                    Add more items from this restaurant
                                </a>
                            </div>
                        <%
                            }
                        %>
                    </div>

                    <div class="cart-summary animate-fade-in" id="cartSummary">
                        <h3>Bill Details</h3>
                        <div class="summary-row">
                            <span class="label">Item Subtotal</span>
                            <span class="value" id="summarySubtotal">₹<%= String.format(java.util.Locale.US, "%.2f", subtotal) %></span>
                        </div>
                        <div class="summary-row">
                            <span class="label">Delivery Fee</span>
                            <span class="value" id="summaryDelivery">₹<%= String.format(java.util.Locale.US, "%.2f", deliveryFee) %></span>
                        </div>
                        <div class="summary-row">
                            <span class="label">Taxes &amp; GST (5%)</span>
                            <span class="value" id="summaryGst">₹<%= String.format(java.util.Locale.US, "%.2f", gst) %></span>
                        </div>
                        <div class="summary-row total">
                            <span class="label">To Pay</span>
                            <span class="value" id="summaryTotal">₹<%= String.format(java.util.Locale.US, "%.2f", total) %></span>
                        </div>
                        
                        <%
                            if (user == null) {
                        %>
                            <a href="login.jsp?redirect=payment.jsp" class="btn btn-primary btn-block" style="margin-top: 24px; text-decoration: none; text-align: center; display: block;">
                                Login to Place Order
                            </a>
                        <%
                            } else {
                        %>
                            <a href="payment.jsp" class="btn btn-primary btn-block" style="margin-top: 24px; text-decoration: none; text-align: center; display: block;">
                                Proceed to Payment
                            </a>
                        <%
                            }
                        %>
                    </div>
                </div>
            <%
                }
            %>
        </div>
    </main>

    <footer></footer>

    <script src="js/app.js"></script>
    <script>
        function updateQty(menuId, newQty, restaurantId) {
            var action = newQty <= 0 ? 'delete' : 'update';
            var url = 'cartServlet?action=' + action + '&menuId=' + menuId + '&restaurantId=' + restaurantId + '&ajax=true';
            if (action === 'update') {
                url += '&quantity=' + newQty;
            }

            fetch(url)
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    if (data.status === 'success') {
                        if (data.itemCount === 0) {
                            // Cart is now empty — reload to show empty state
                            location.reload();
                            return;
                        }
                        // Update bill summary
                        document.getElementById('summarySubtotal').textContent = '₹' + parseFloat(data.subtotal).toFixed(2);
                        document.getElementById('summaryGst').textContent = '₹' + parseFloat(data.gst).toFixed(2);
                        document.getElementById('summaryTotal').textContent = '₹' + parseFloat(data.total).toFixed(2);

                        // Update header badge
                        var badge = document.querySelector('.cart-count');
                        if (badge) badge.textContent = data.itemCount;

                        // If item was removed (qty=0), remove the DOM element
                        if (newQty <= 0) {
                            var el = document.getElementById('cart-item-' + menuId);
                            if (el) el.remove();
                            return;
                        }

                        // Find the item in the response and update its qty + total
                        for (var i = 0; i < data.items.length; i++) {
                            var ci = data.items[i];
                            if (ci.menuId === menuId) {
                                document.getElementById('qty-' + menuId).textContent = ci.quantity;
                                document.getElementById('total-' + menuId).textContent = '₹' + parseFloat(ci.totalPrice).toFixed(2);

                                // Update the onclick handlers with new quantity values
                                var itemEl = document.getElementById('cart-item-' + menuId);
                                var btns = itemEl.querySelectorAll('.qty-btn');
                                btns[0].setAttribute('onclick', 'updateQty(' + menuId + ', ' + (ci.quantity - 1) + ', ' + restaurantId + ')');
                                btns[1].setAttribute('onclick', 'updateQty(' + menuId + ', ' + (ci.quantity + 1) + ', ' + restaurantId + ')');
                                break;
                            }
                        }
                    }
                })
                .catch(function(err) {
                    console.error('Cart update error:', err);
                });
        }

        function removeItem(menuId, restaurantId) {
            updateQty(menuId, 0, restaurantId);
        }
    </script>
</body>
</html>


