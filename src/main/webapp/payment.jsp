<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.food.model.Cart, com.food.model.CartItem, com.food.model.User, java.util.Collection" %>
<%
    // Verify user and cart exist - touched to trigger Eclipse revalidation
    User user = (User) session.getAttribute("user");
    Cart cart = (Cart) session.getAttribute("cart");

    if (user == null) {
        response.sendRedirect("login.jsp?redirect=payment.jsp");
        return;
    }

    if (cart == null || cart.isEmpty()) {
        response.sendRedirect("callRestaurantServlet");
        return;
    }

    double subtotal = cart.getTotalPrice();
    double deliveryFee = 40.00;
    double gst = subtotal * 0.05;
    double total = subtotal + deliveryFee + gst;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Payment - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/payment.css">
    <script>
        window.DIVA_USER = {
            name: "<%= user != null ? user.getUserName().replace("\"", "\\\"").replace("\n", "") : "" %>",
            role: "<%= user != null ? user.getRole() : "" %>"
        };
        if (!window.DIVA_USER.name) window.DIVA_USER = null;
        window.DIVA_CART_COUNT = <%= cart != null ? cart.getItems().size() : 0 %>;
    </script>
</head>
<body>
    <header></header>

    <main class="container payment-page page-header">
        <a href="cart.jsp" class="back-link">← Back to Cart</a>
        <h1 style="font-family: var(--font-heading); margin-bottom: 24px;">Choose Payment Method</h1>

        <div class="payment-layout">
            <div class="payment-methods">
                <div class="payment-method selected" onclick="selectMethod(this, 'UPI')">
                    <div class="method-icon">📱</div>
                    <div class="method-info">
                        <h3>UPI (GPay / PhonePe / Paytm)</h3>
                        <p>Pay instantly using any UPI app</p>
                    </div>
                </div>

                <div class="payment-method" onclick="selectMethod(this, 'CARD')">
                    <div class="method-icon">💳</div>
                    <div class="method-info">
                        <h3>Credit or Debit Card</h3>
                        <p>Visa, Mastercard, RuPay, Maestro supported</p>
                    </div>
                </div>

                <div class="payment-method" onclick="selectMethod(this, 'NETBANKING')">
                    <div class="method-icon">👛</div>
                    <div class="method-info">
                        <h3>Net Banking / Digital Wallets</h3>
                        <p>Amazon Pay, Paytm Wallet, and top banks</p>
                    </div>
                </div>

                <div class="payment-method" onclick="selectMethod(this, 'COD')">
                    <div class="method-icon">💵</div>
                    <div class="method-info">
                        <h3>Cash on Delivery (COD)</h3>
                        <p>Pay cash or scan QR code on delivery</p>
                    </div>
                </div>
            </div>

            <div class="cart-summary animate-fade-in">
                <h3>Order Summary</h3>
                <div id="summaryItems">
                    <%
                        java.util.Iterator<CartItem> it = cart.getItems().values().iterator();
                        while (it.hasNext()) {
                            CartItem item = it.next();
                    %>
                        <div class="summary-row" style="font-size: 0.88rem; padding: 6px 0;">
                            <span class="label"><%= item.getName() %> (x<%= item.getQuantity() %>)</span>
                            <span class="value">₹<%= String.format(java.util.Locale.US, "%.2f", item.getTotalPrice()) %></span>
                        </div>
                    <%
                        }
                    %>
                </div>
                <div class="summary-row total" style="margin-top: 16px;">
                    <span class="label">Amount to Pay</span>
                    <span class="value">₹<%= String.format(java.util.Locale.US, "%.2f", total) %></span>
                </div>

                <!-- Interactive Delivery Address Section -->
                <div class="address-confirmation-card animate-fade-in" style="margin-top: 24px; padding: 20px; background: rgba(255,255,255,0.02); border: 1px solid var(--border); border-radius: var(--radius-lg); box-shadow: var(--shadow-md);">
                    <h4 style="font-family: var(--font-heading); margin-bottom: 8px; display: flex; align-items: center; gap: 8px; font-size: 1rem;">
                        📍 <span>Delivery Address</span>
                    </h4>
                    <div id="addressDisplayState">
                        <p id="addressText" style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.5; margin-bottom: 12px;"><%= user.getAddress() != null && !user.getAddress().trim().isEmpty() ? user.getAddress() : "No delivery address specified. Please add one." %></p>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="showEditAddress()" style="font-size: 0.78rem; padding: 4px 8px;">Change Address</button>
                    </div>
                    <div id="addressEditState" style="display: none;">
                        <textarea id="addressInput" style="width: 100%; padding: 8px 12px; background: var(--bg-input); border: 1px solid var(--border); border-radius: var(--radius-md); color: white; font-family: var(--font-body); font-size: 0.9rem;" rows="3" placeholder="Enter your full delivery address in Bangalore..."><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                        <div style="display: flex; gap: 8px; margin-top: 10px;">
                            <button type="button" class="btn btn-primary btn-sm" onclick="saveAddressConfirm()" style="font-size: 0.78rem; padding: 4px 8px;">Confirm</button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="cancelEditAddress()" style="font-size: 0.78rem; padding: 4px 8px;">Cancel</button>
                        </div>
                    </div>
                </div>

                <!-- Form submits to CheckoutServlet -->
                <form id="checkoutForm" action="checkout" method="POST">
                    <input type="hidden" id="paymentMode" name="paymentMode" value="UPI">
                    <input type="hidden" id="deliveryAddress" name="deliveryAddress" value="<%= user.getAddress() != null ? user.getAddress() : "" %>">
                    <button type="submit" class="btn btn-primary btn-block" style="margin-top: 24px;">
                        Confirm &amp; Place Order
                    </button>
                </form>
            </div>
        </div>
    </main>

    <footer></footer>

    <script src="js/app.js"></script>
    <script>
        function selectMethod(element, method) {
            document.querySelectorAll(".payment-method").forEach(el => {
                el.classList.remove("selected");
            });
            element.classList.add("selected");
            document.getElementById("paymentMode").value = method;
        }

        function showEditAddress() {
            document.getElementById("addressDisplayState").style.display = "none";
            document.getElementById("addressEditState").style.display = "block";
        }
        function cancelEditAddress() {
            document.getElementById("addressDisplayState").style.display = "block";
            document.getElementById("addressEditState").style.display = "none";
        }
        function saveAddressConfirm() {
            const val = document.getElementById("addressInput").value.trim();
            if (val === "") {
                alert("Please enter a valid delivery address.");
                return;
            }
            document.getElementById("addressText").textContent = val;
            document.getElementById("deliveryAddress").value = val;
            cancelEditAddress();
        }
    </script>
</body>
</html>


