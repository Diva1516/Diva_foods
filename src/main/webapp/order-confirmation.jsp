<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.food.model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="com.food.model.OrderItem" %>
<%@ page import="com.food.model.Menu" %>
<%@ page import="com.food.model.Restaurant" %>
<%@ page import="com.food.DAOimpl.OrderItemDAOImpl" %>
<%@ page import="com.food.DAOimpl.MenuDAOImpl" %>
<%@ page import="com.food.DAOimpl.RestaurantDAOImpl" %>
<%
    Order order = (Order) request.getAttribute("order");
    String paymentMethod = (String) request.getAttribute("paymentMethod");
    String deliveryAddress = (String) request.getAttribute("deliveryAddress");

    // If order is null (accessed directly), redirect to restaurants listing
    if (order == null) {
        response.sendRedirect("callRestaurantServlet");
        return;
    }

    OrderItemDAOImpl orderItemDAO = new OrderItemDAOImpl();
    MenuDAOImpl menuDAO = new MenuDAOImpl();
    RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();

    List<OrderItem> items = orderItemDAO.getOrderItemsByOrder(order.getOrderID());
    Restaurant rest = restaurantDAO.getRestaurant(order.getRestaurantID());
    int deliveryTimeMins = (rest != null) ? rest.getDeliveryTime() : 30;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/payment.css">
    <script>
        <% com.food.model.User user = (com.food.model.User) session.getAttribute("user"); %>
        window.DIVA_USER = {
            name: "<%= user != null ? user.getUserName().replace("\"", "\\\"").replace("\n", "") : "" %>",
            role: "<%= user != null ? user.getRole() : "" %>"
        };
        if (!window.DIVA_USER.name) window.DIVA_USER = null;
        <% com.food.model.Cart c = (com.food.model.Cart) session.getAttribute("cart"); %>
        window.DIVA_CART_COUNT = <%= c != null ? c.getItems().size() : 0 %>;
    </script>
    <style>
        .live-countdown {
            font-size: 1.1rem;
            font-weight: 700;
            color: #ffc107;
            margin-top: 12px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(255, 193, 7, 0.1);
            padding: 8px 16px;
            border-radius: var(--radius-full);
            border: 1px solid rgba(255, 193, 7, 0.2);
        }
        .pulse-dot {
            width: 10px;
            height: 10px;
            background: #ffc107;
            border-radius: 50%;
            animation: pulse-dot 1.5s infinite;
        }
        @keyframes pulse-dot {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.5); opacity: 0.5; }
            100% { transform: scale(1); opacity: 1; }
        }
        .order-items-list {
            margin: 20px 0;
            padding: 16px 20px;
            background: rgba(255, 255, 255, 0.02);
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            text-align: left;
        }
        .order-item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            font-size: 0.95rem;
            border-bottom: 1px solid var(--border);
        }
        .order-item-row:last-child {
            border-bottom: none;
        }
        .order-item-name {
            flex: 1;
            color: var(--text-primary);
            font-weight: 500;
        }
        .order-item-qty {
            color: var(--text-secondary);
            margin: 0 24px;
            min-width: 50px;
            text-align: center;
            background: var(--bg-glass);
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.85rem;
        }
        .order-item-price {
            font-weight: 600;
            color: var(--text-primary);
            min-width: 80px;
            text-align: right;
        }
    </style>
</head>
<body>
    <header></header>

    <main class="confirmation-page">
        <div class="confirmation-card animate-fade-in" style="max-width: 600px;">
            <div class="success-icon">✓</div>
            <h1>Order Placed Successfully!</h1>
            <p style="color: var(--text-secondary); margin-bottom: 8px;">Your order has been sent to <%= (rest != null) ? rest.getName() : "the kitchen" %>.</p>
            
            <div class="live-countdown" id="confirm-countdown" data-time="<%= order.getOrderDate().getTime() %>" data-eta="<%= deliveryTimeMins %>">
                <span class="pulse-dot"></span> Arriving in <span class="time-display">--:--</span>
            </div>

            <div class="order-id" style="margin-top: 24px;">Order ID: <%= String.format("DF%03d", order.getOrderID()) %></div>

            <div class="order-items-list">
                <%
                    if (items != null && !items.isEmpty()) {
                        for (OrderItem oi : items) {
                            Menu menuItem = menuDAO.getMenu(oi.getMenuID());
                            String itemName = (menuItem != null) ? menuItem.getItemName() : "Menu Item";
                %>
                            <div class="order-item-row">
                                <span class="order-item-name"><%= itemName %></span>
                                <span class="order-item-qty">x<%= oi.getQuantity() %></span>
                                <span class="order-item-price">₹<%= String.format(java.util.Locale.US, "%.2f", oi.getItemTotal()) %></span>
                            </div>
                <%
                        }
                    }
                %>
            </div>

            <div class="order-details">
                <div class="detail-row">
                    <span class="label">Payment Mode</span>
                    <span class="value"><%= paymentMethod != null ? paymentMethod : "UPI" %></span>
                </div>
                <div class="detail-row">
                    <span class="label">Delivery Address</span>
                    <span class="value"><%= deliveryAddress != null ? deliveryAddress : "Bangalore" %></span>
                </div>
                <div class="detail-row" style="margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--border);">
                    <span class="label" style="font-weight: 700; color: var(--text-primary); font-size: 1.1rem;">Total Amount Paid</span>
                    <span class="value" style="font-size: 1.2rem; font-weight: 700; color: var(--accent);">₹<%= String.format(java.util.Locale.US, "%.2f", order.getTotalAmount()) %></span>
                </div>
            </div>

            <div style="display: flex; gap: 16px; justify-content: center; margin-top: 24px;">
                <a href="callRestaurantServlet" class="btn btn-primary" style="text-decoration: none;">Order More Food</a>
                <a href="orderHistory" class="btn btn-secondary" style="text-decoration: none;">View Order Status</a>
            </div>
        </div>
    </main>

    <footer></footer>

    <script src="js/app.js?v=3"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function initConfirmationTimer() {
            const el = document.getElementById('confirm-countdown');
            if (!el) return;

            const orderTime = parseInt(el.getAttribute('data-time'));
            const etaMins = parseInt(el.getAttribute('data-eta'));
            const targetTime = orderTime + (etaMins * 60 * 1000);
            const timeDisplay = el.querySelector('.time-display');

            function updateTimer() {
                const now = Date.now();
                const diff = targetTime - now;

                if (diff > 0) {
                    const mins = Math.floor(diff / 1000 / 60);
                    const secs = Math.floor((diff / 1000) % 60);
                    timeDisplay.innerText = mins + ":" + (secs < 10 ? '0' : '') + secs;
                } else {
                    timeDisplay.innerText = "Delivered!";
                    if (el.style.background !== "rgba(40, 167, 69, 0.1)") {
                        el.style.background = "rgba(40, 167, 69, 0.1)";
                        el.style.color = "#28a745";
                        el.style.borderColor = "rgba(40, 167, 69, 0.2)";
                        el.querySelector('.pulse-dot').style.display = 'none';
                        Swal.fire({
                            icon: 'success',
                            title: 'Order Delivered!',
                            text: 'Your order has successfully arrived.',
                            confirmButtonColor: '#28a745'
                        });
                    }
                }
            }

            updateTimer();
            setInterval(updateTimer, 1000);
        }

        initConfirmationTimer();
    </script>
</body>
</html>


