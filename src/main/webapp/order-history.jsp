<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.food.model.Order, com.food.model.User, com.food.model.OrderItem, com.food.model.Menu, com.food.model.Restaurant, com.food.model.Cart" %>
<%@ page import="com.food.DAOimpl.OrderItemDAOImpl, com.food.DAOimpl.MenuDAOImpl, com.food.DAOimpl.RestaurantDAOImpl, com.food.DAOimpl.UserDAOImpl" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp?redirect=orderHistory");
        return;
    }
    List<Order> orderList = (List<Order>) request.getAttribute("orderList");
    OrderItemDAOImpl orderItemDAO = new OrderItemDAOImpl();
    MenuDAOImpl menuDAO = new MenuDAOImpl();
    RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
    UserDAOImpl userDAO = new UserDAOImpl();
    
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
    <title>My Orders - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <script>
        window.DIVA_USER = {
            name: "<%= user != null ? user.getUserName().replace("\"", "\\\"").replace("\n", "") : "" %>",
            role: "<%= user != null ? user.getRole() : "" %>"
        };
        if (!window.DIVA_USER.name) window.DIVA_USER = null;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
    <style>
        .orders-container {
            max-width: 850px;
            margin: 100px auto 40px auto;
            padding: 0 16px;
        }
        .page-title {
            font-family: var(--font-heading);
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 8px;
            background: var(--accent-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .page-subtitle {
            color: var(--text-secondary);
            margin-bottom: 40px;
            font-size: 1rem;
        }
        .order-card {
            background: var(--bg-secondary);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 28px;
            margin-bottom: 30px;
            box-shadow: var(--shadow-md);
            transition: all var(--transition-base);
        }
        .order-card:hover {
            border-color: var(--accent);
            box-shadow: var(--shadow-lg), var(--shadow-glow);
            transform: translateY(-2px);
        }
        .order-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 1px solid var(--border);
            padding-bottom: 16px;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }
        .order-id-label {
            font-size: 1.2rem;
            font-family: var(--font-heading);
            font-weight: 700;
            color: var(--text-primary);
        }
        .restaurant-name {
            font-size: 1rem;
            color: var(--accent-light);
            font-weight: 600;
            margin-top: 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .status-badge {
            padding: 6px 16px;
            border-radius: var(--radius-full);
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            border: 1px solid transparent;
            display: inline-block;
        }
        .status-pending { background: rgba(255, 193, 7, 0.1); color: #ffc107; border-color: rgba(255, 193, 7, 0.2); }
        .status-confirmed { background: rgba(23, 162, 184, 0.1); color: #17a2b8; border-color: rgba(23, 162, 184, 0.2); }
        .status-preparing { background: rgba(0, 123, 255, 0.1); color: #007bff; border-color: rgba(0, 123, 255, 0.2); }
        .status-out_for_delivery { background: rgba(253, 126, 20, 0.1); color: #fd7e14; border-color: rgba(253, 126, 20, 0.2); }
        .status-delivered { background: rgba(40, 167, 69, 0.1); color: #28a745; border-color: rgba(40, 167, 69, 0.2); }
        .status-cancelled { background: rgba(220, 53, 69, 0.1); color: #dc3545; border-color: rgba(220, 53, 69, 0.2); text-decoration: line-through; opacity: 0.8; }
        
        .live-countdown {
            font-size: 0.95rem;
            font-weight: 600;
            color: #ffc107;
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .pulse-dot {
            width: 8px;
            height: 8px;
            background: #ffc107;
            border-radius: 50%;
            animation: pulse-dot 1.5s infinite;
        }
        @keyframes pulse-dot {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.5); opacity: 0.5; }
            100% { transform: scale(1); opacity: 1; }
        }
        .btn-cancel {
            background: none;
            border: 1px solid var(--danger);
            color: var(--danger);
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 8px;
            transition: all 0.2s;
        }
        .btn-cancel:hover {
            background: var(--danger);
            color: white;
        }

        .order-items-list {
            margin: 16px 0 24px 0;
            padding: 16px 20px;
            background: rgba(255, 255, 255, 0.01);
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
        }
        .order-item-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            font-size: 0.95rem;
            flex-wrap: wrap;
            gap: 8px;
        }
        .order-item-row:not(:last-child) {
            border-bottom: 1px solid var(--border);
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

        .order-card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }
        .order-date {
            font-size: 0.9rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .order-total-container {
            text-align: right;
        }
        .order-total-label {
            font-size: 0.8rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .order-total {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--accent);
            margin-top: 2px;
        }
        .payment-badge {
            font-size: 0.8rem;
            padding: 4px 12px;
            border-radius: var(--radius-full);
            background: var(--bg-glass);
            color: var(--text-secondary);
            font-weight: 600;
            border: 1px solid var(--border);
            text-transform: uppercase;
        }
    </style>
</head>
<body>
    <header></header>

    <main class="orders-container page-header">
        <a href="callRestaurantServlet" class="back-link" style="display: inline-block; margin-bottom: 20px; color: var(--accent); font-weight: 600; text-decoration: none;">← Back to Restaurants</a>
        <h1 class="page-title">My Order History</h1>
        <p class="page-subtitle">Track status and view details of your past delicious orders.</p>

        <%
            if (orderList == null || orderList.isEmpty()) {
        %>
            <div class="cart-empty animate-fade-in" style="text-align: center; padding: 60px 20px; background: var(--bg-secondary); border: 1px solid var(--border); border-radius: var(--radius-lg);">
                <div class="empty-icon" style="font-size: 4rem; margin-bottom: 20px;">🍽️</div>
                <h2 style="font-family: var(--font-heading); font-size: 1.6rem; margin-bottom: 12px;">No Orders Placed Yet</h2>
                <p style="color: var(--text-secondary); margin-bottom: 24px; max-width: 460px; margin-left: auto; margin-right: auto;">You haven't ordered anything yet. Let's change that! Choose from Bangalore's finest restaurants and place your first order.</p>
                <a href="callRestaurantServlet" class="btn btn-primary" style="text-decoration: none; display: inline-block;">Discover Food</a>
            </div>
        <%
            } else {
                for (int i = 0; i < orderList.size(); i++) {
                    Order order = orderList.get(i);
                    String statusClass = "status-" + order.getStatus().toLowerCase().replace(' ', '_');
                    // Fetch restaurant name
                    Restaurant rest = restaurantDAO.getRestaurant(order.getRestaurantID());
                    String restName = (rest != null) ? rest.getName() : "Restaurant";
                    // Fetch order items
                    List<OrderItem> items = orderItemDAO.getOrderItemsByOrder(order.getOrderID());
                    
                    int deliveryTimeMins = (rest != null) ? rest.getDeliveryTime() : 30;
                    
                    // Fetch delivery agent
                    String agentName = null;
                    if (order.getDeliveryAgentId() != null) {
                        User agent = userDAO.getUser(order.getDeliveryAgentId());
                        if (agent != null) {
                            agentName = agent.getUserName();
                        }
                    }
        %>
                    <div class="order-card animate-fade-in animate-delay-<%= (i % 5) + 1 %>">
                        <div class="order-card-header">
                            <div>
                                <div class="order-id-label">Order #<%= String.format("DF%03d", order.getOrderID()) %></div>
                                <div class="restaurant-name">🏪 <%= restName %></div>
                            </div>
                            <div style="display: flex; flex-direction: column; align-items: flex-end;">
                                <span class="status-badge <%= statusClass %>" id="status-badge-<%= order.getOrderID() %>">
                                    <% if ("Pending".equalsIgnoreCase(order.getStatus()) && isPast15Mins) { %>
                                        SHIPPED OR PROCESSED
                                    <% } else { %>
                                        <%= order.getStatus() %>
                                    <% } %>
                                </span>
                                <% if ("Pending".equalsIgnoreCase(order.getStatus())) { 
                                    if (!isPast15Mins) {
                                %>
                                    <div class="live-countdown" id="countdown-<%= order.getOrderID() %>" data-time="<%= orderTimeMs %>" data-eta="<%= deliveryTimeMins %>">
                                        <span class="pulse-dot"></span> Arriving in <span class="time-display">--:--</span>
                                    </div>
                                    <button type="button" class="btn-cancel" onclick="cancelOrder(<%= order.getOrderID() %>, <%= orderTimeMs %>, <%= deliveryTimeMins %>)">Cancel Order</button>
                                <% } else { %>
                                    <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 8px;">
                                        <span class="pulse-dot" style="background-color: #28a745;"></span> Arriving in <span class="time-display">--:--</span>
                                    </div>
                                <% }
                                } else if ("out_for_delivery".equalsIgnoreCase(order.getStatus()) && agentName != null) { %>
                                    <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 8px; font-weight: 600;">
                                        🛵 Picked up by: <span style="color: var(--accent);"><%= agentName %></span>
                                    </div>
                                <% } else if ("Delivered".equalsIgnoreCase(order.getStatus()) && agentName != null) { %>
                                    <button type="button" class="btn-cancel" style="border-color: var(--accent); color: var(--accent); margin-top: 8px;" onclick="openReviewModal(<%= order.getOrderID() %>, <%= order.getDeliveryAgentId() %>, '<%= agentName %>')">⭐ Rate Delivery</button>
                                <% } %>
                            </div>
                        </div>

                        <div class="order-items-list">
                            <%
                                if (items != null) {
                                    for (int j = 0; j < items.size(); j++) {
                                        OrderItem oi = items.get(j);
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

                        <div class="order-card-footer">
                            <span class="order-date">📅 <%= order.getOrderDate() %></span>
                            <span class="payment-badge">💳 <%= order.getPaymentMethod() %></span>
                            <div class="order-total-container">
                                <div class="order-total-label">Total Paid</div>
                                <div class="order-total">₹<%= String.format(java.util.Locale.US, "%.2f", order.getTotalAmount()) %></div>
                            </div>
                        </div>
                    </div>
        <%
                }
            }
        %>
        
        <!-- Delivery Agent Review Modal -->
        <div id="reviewModal" class="modal" style="display:none; position:fixed; z-index:9999; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.7); backdrop-filter:blur(5px); display:none; align-items:center; justify-content:center;">
            <div class="modal-content" style="background:var(--bg-secondary); padding:30px; border-radius:16px; width:90%; max-width:400px; border:1px solid var(--border); box-shadow:var(--shadow-lg);">
                <h3 style="margin-bottom:10px; font-family:var(--font-heading); font-size:1.4rem;">Rate Delivery</h3>
                <p style="color:var(--text-secondary); margin-bottom:20px; font-size:0.9rem;">How was your delivery by <strong id="reviewAgentName" style="color:var(--text-primary);">Agent</strong>?</p>
                <form action="submitDeliveryReview" method="POST">
                    <input type="hidden" name="orderId" id="reviewOrderId">
                    <input type="hidden" name="agentId" id="reviewAgentId">
                    <div style="margin-bottom:20px; display:flex; gap:10px; font-size:2rem; cursor:pointer;" id="starRatingContainer">
                        <span class="star" data-value="1" style="color:#555;">★</span>
                        <span class="star" data-value="2" style="color:#555;">★</span>
                        <span class="star" data-value="3" style="color:#555;">★</span>
                        <span class="star" data-value="4" style="color:#555;">★</span>
                        <span class="star" data-value="5" style="color:#555;">★</span>
                    </div>
                    <input type="hidden" name="rating" id="reviewRatingValue" value="5" required>
                    <textarea name="comments" placeholder="Leave a nice comment (optional)..." style="width:100%; background:var(--bg-primary); border:1px solid var(--border); padding:12px; border-radius:8px; color:white; resize:none; margin-bottom:20px;" rows="3"></textarea>
                    <div style="display:flex; gap:10px;">
                        <button type="button" class="btn btn-secondary" style="flex:1;" onclick="document.getElementById('reviewModal').style.display='none'">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="flex:1;">Submit Review</button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <footer></footer>

    <script src="js/app.js?v=2"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        // Live Countdown Logic
        function initCountdowns() {
            const countdownElements = document.querySelectorAll('.live-countdown');
            if (countdownElements.length === 0) return;

            function updateTimers() {
                const now = Date.now();
                countdownElements.forEach(el => {
                    const orderTime = parseInt(el.getAttribute('data-time'));
                    const etaMins = parseInt(el.getAttribute('data-eta'));
                    const targetTime = orderTime + (etaMins * 60 * 1000);
                    const diff = targetTime - now;

                    console.log("orderTime:", orderTime, "now:", now, "diff:", diff);

                    const timeDisplay = el.querySelector('.time-display');
                    const orderCard = el.closest('.order-card-header');
                    const cancelBtn = orderCard.querySelector('.btn-cancel');
                    const badge = orderCard.querySelector('.status-badge');

                    if (diff > 0) {
                        const mins = Math.floor(diff / 1000 / 60);
                        const secs = Math.floor((diff / 1000) % 60);
                        timeDisplay.innerText = mins + ":" + (secs < 10 ? '0' : '') + secs;
                    } else {
                        if (badge && badge.innerText.trim() !== 'DELIVERED') {
                            badge.innerText = 'DELIVERED';
                            badge.className = 'status-badge status-delivered';
                            el.innerHTML = '<span style="color:var(--text-secondary);">Delivered</span>';
                            if (cancelBtn) cancelBtn.remove();
                            
                            // Only fire the alert if this specific order just changed to delivered right now
                            Swal.fire({
                                icon: 'success',
                                title: 'Order Delivered!',
                                text: 'Your order has successfully arrived.',
                                confirmButtonColor: '#28a745'
                            });
                        }
                    }
                });
            }

            // Run immediately once, then set interval
            updateTimers();
            setInterval(updateTimers, 1000);
        }

        // Run immediately since script is at end of body
        initCountdowns();

        // Cancel Order Logic
        function cancelOrder(orderId, orderTimeMs, etaMins) {
            const now = Date.now();
            const targetTime = orderTimeMs + (etaMins * 60 * 1000);
            const remainingMins = (targetTime - now) / 1000 / 60;

            if (remainingMins < 15) {
                Swal.fire({
                    icon: 'error',
                    title: 'Unable to Cancel',
                    text: 'Your order is already being prepared by the restaurant and can no longer be cancelled.',
                    confirmButtonColor: 'var(--accent)'
                });
                return;
            }

            Swal.fire({
                title: 'Confirm Cancellation',
                text: 'Are you sure you want to cancel your order?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: 'var(--danger)',
                cancelButtonColor: 'var(--text-secondary)',
                confirmButtonText: 'Yes, Cancel it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    const reason = 'User requested cancellation';
                    
                    fetch('cancelOrderServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: "orderId=" + orderId + "&reason=" + encodeURIComponent(reason)
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.status === 'success') {
                            Swal.fire({
                                icon: 'success',
                                title: 'Cancelled',
                                text: 'Your order has been cancelled successfully.',
                                confirmButtonColor: 'var(--accent)'
                            }).then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire('Error', data.message || 'Failed to cancel order.', 'error');
                        }
                    })
                    .catch(err => {
                        Swal.fire('Error', 'Network error occurred.', 'error');
                    });
                }
            });
        }

        // Review Modal Logic
        function openReviewModal(orderId, agentId, agentName) {
            document.getElementById('reviewOrderId').value = orderId;
            document.getElementById('reviewAgentId').value = agentId;
            document.getElementById('reviewAgentName').innerText = agentName;
            document.getElementById('reviewModal').style.display = 'flex';
            
            // Setup stars
            const stars = document.querySelectorAll('.star');
            const ratingInput = document.getElementById('reviewRatingValue');
            
            // Set default 5 stars
            stars.forEach(s => s.style.color = '#ffc107');
            
            stars.forEach(star => {
                star.onclick = function() {
                    const rating = parseInt(this.getAttribute('data-value'));
                    ratingInput.value = rating;
                    stars.forEach(s => {
                        if (parseInt(s.getAttribute('data-value')) <= rating) {
                            s.style.color = '#ffc107';
                        } else {
                            s.style.color = '#555';
                        }
                    });
                };
            });
        }
    </script>
</body>
</html>
