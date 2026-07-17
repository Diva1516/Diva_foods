<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, com.food.model.Order, com.food.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"delivery".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    Double earnings = (Double) request.getAttribute("earnings");
    Integer completedCount = (Integer) request.getAttribute("completedCount");
    List<Order> availableJobs = (List<Order>) request.getAttribute("availableJobs");
    List<Order> activeJobs = (List<Order>) request.getAttribute("activeJobs");
    Map<Integer, Integer> orderEtas = (Map<Integer, Integer>) request.getAttribute("orderEtas");
    Map<Integer, Long> orderTimes = (Map<Integer, Long>) request.getAttribute("orderTimes");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/logo.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Dashboard - Diva Foods</title>
    <link rel="stylesheet" href="../css/common.css?v=1.3">
    <link rel="stylesheet" href="../css/delivery.css?v=1.3">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        window.DIVA_USER = {"name": "<%= currentUser.getUserName() %>", "role": "<%= currentUser.getRole() %>"};
    </script>
</head>
<body>
    <header></header>
    <main class="delivery-layout">
        <!-- Delivery Agent Status Toggle -->
        <div class="status-toggle-container" style="display: flex; justify-content: space-between; align-items: center; background: rgba(255, 255, 255, 0.05); padding: 15px 24px; border-radius: 12px; margin-bottom: 24px; border: 1px solid rgba(255,255,255,0.08);">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div id="statusIndicator" style="width: 14px; height: 14px; border-radius: 50%; background: #28a745; box-shadow: 0 0 12px #28a745; transition: all 0.3s ease;"></div>
                <span id="statusText" style="font-weight: 700; font-size: 1.1rem; letter-spacing: 0.5px;">You are Online</span>
            </div>
            <label class="switch" style="position: relative; display: inline-block; width: 60px; height: 32px; margin: 0;">
                <input type="checkbox" id="riderStatusToggle" checked onchange="toggleRiderStatus(this)" style="opacity: 0; width: 0; height: 0;">
                <span class="slider round" style="position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: var(--accent); transition: .4s; border-radius: 34px;">
                    <span class="knob" style="position: absolute; content: ''; height: 24px; width: 24px; left: 4px; bottom: 4px; background-color: white; transition: .4s; border-radius: 50%; transform: translateX(28px);"></span>
                </span>
            </label>
        </div>
        
        <script>
            function toggleRiderStatus(checkbox) {
                const indicator = document.getElementById('statusIndicator');
                const text = document.getElementById('statusText');
                const slider = checkbox.nextElementSibling;
                const knob = slider.querySelector('.knob');
                
                if (checkbox.checked) {
                    indicator.style.background = '#28a745';
                    indicator.style.boxShadow = '0 0 12px #28a745';
                    text.textContent = 'You are Online';
                    slider.style.backgroundColor = 'var(--accent)';
                    knob.style.transform = 'translateX(28px)';
                } else {
                    indicator.style.background = '#dc3545';
                    indicator.style.boxShadow = '0 0 12px #dc3545';
                    text.textContent = 'You are Offline';
                    slider.style.backgroundColor = '#444';
                    knob.style.transform = 'translateX(0)';
                }
            }
        </script>

        <div class="earnings-card">
            <h2>Your Today's Payout</h2>
            <div class="amount">₹<%= earnings != null ? String.format(java.util.Locale.US, "%.2f", earnings) : "0.00" %></div>
            <p style="margin-top: 10px; font-size: 0.9rem; opacity: 0.8;">Completed Deliveries: <%= completedCount != null ? completedCount : 0 %></p>
        </div>

        <!-- 1. Active Delivery Section -->
        <h2 style="font-family: var(--font-heading); margin-bottom: 20px;">Active Delivery</h2>
        <div class="jobs-list" style="margin-bottom: 40px;">
            <%
                if (activeJobs == null || activeJobs.isEmpty()) {
            %>
                <div class="job-card" style="text-align: center; color: var(--text-muted);">
                    No active deliveries. Accept a job from the list below to get started!
                </div>
            <%
                } else {
                    for (Order order : activeJobs) {
            %>
                        <div class="job-card" style="border-color: var(--accent);">
                            <div class="job-header">
                                <span class="job-restaurant">Active Order #DIVA-<%= order.getOrderID() %></span>
                                <span class="job-payout">Payout: ₹40.00</span>
                            </div>
                            
                            <div class="status-stepper">
                                <div class="step-node completed" title="Order Placed">1</div>
                                <div class="step-node completed" title="Preparing">2</div>
                                <div class="step-node completed" title="Ready for Pick Up">3</div>
                                <div class="step-node active" title="On the Way">4</div>
                                <div class="step-node" title="Delivered">5</div>
                            </div>

                            <div class="job-details">
                                <div>
                                    <span class="label">Delivery Address</span>
                                    <span class="value"><%= currentUser.getAddress() %></span>
                                </div>
                                <div>
                                    <span class="label">Time Remaining</span>
                                    <div class="live-countdown" id="countdown-<%= order.getOrderID() %>" data-time="<%= orderTimes.get(order.getOrderID()) %>" data-eta="<%= orderEtas.get(order.getOrderID()) %>">
                                        <span class="pulse-dot"></span> <span class="time-display" style="font-weight: 700; color: var(--accent);">--:--</span>
                                    </div>
                                </div>
                            </div>
                            
                            <form action="dashboard" method="POST" style="margin: 0;" onsubmit="handleDeliveryConfirm(event, this)">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                <button type="submit" class="btn btn-primary btn-block">Confirm Delivery & Handover</button>
                            </form>
                        </div>
            <%
                    }
                }
            %>
        </div>

        <!-- 2. Available Jobs Section -->
        <h2 style="font-family: var(--font-heading); margin-bottom: 20px;">Available Jobs Near You</h2>
        <div class="jobs-list">
            <%
                if (availableJobs == null || availableJobs.isEmpty()) {
            %>
                <div class="job-card" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                    No pending pickup jobs at the moment. Check back soon!
                </div>
            <%
                } else {
                    for (Order order : availableJobs) {
            %>
                        <div class="job-card">
                            <div class="job-header">
                                <span class="job-restaurant">Pickup from Restaurant ID: <%= order.getRestaurantID() %></span>
                                <span class="job-payout">Payout: ₹40.00</span>
                            </div>
                            <div class="job-details">
                                <div>
                                    <span class="label">Customer Address</span>
                                    <span class="value">Address details on accept</span>
                                </div>
                                <div>
                                    <span class="label">Est. Time</span>
                                    <span class="value">20 mins</span>
                                </div>
                            </div>
                            <form action="dashboard" method="POST" style="margin: 0;">
                                <input type="hidden" name="action" value="accept">
                                <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                <button type="submit" class="btn btn-secondary btn-block">Accept Delivery Job</button>
                            </form>
                        </div>
            <%
                    }
                }
            %>
        </div>
    </main>

    <footer></footer>
    <script src="../js/app.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            injectNavigation();
            injectFooter();
            initCountdowns();
        });

        function handleDeliveryConfirm(event, form) {
            event.preventDefault();
            Swal.fire({
                icon: 'success',
                title: 'Order Delivered!',
                text: 'You have successfully delivered the order. The payout has been credited to your account!',
                confirmButtonColor: 'var(--accent)'
            }).then(() => {
                form.submit();
            });
        }

        function initCountdowns() {
            const timers = document.querySelectorAll('.live-countdown');
            if (timers.length === 0) return;

            function updateTimers() {
                const now = Date.now();
                timers.forEach(timer => {
                    const orderTime = parseInt(timer.getAttribute('data-time'));
                    const etaMins = parseInt(timer.getAttribute('data-eta'));
                    const targetTime = orderTime + (etaMins * 60 * 1000);
                    const diff = targetTime - now;

                    const timeDisplay = timer.querySelector('.time-display');

                    if (diff > 0) {
                        const mins = Math.floor(diff / 1000 / 60);
                        const secs = Math.floor((diff / 1000) % 60);
                        timeDisplay.innerText = mins + ":" + (secs < 10 ? '0' : '') + secs;
                        timer.style.color = 'var(--text-primary)';
                    } else {
                        timeDisplay.innerText = "OVERDUE";
                        timeDisplay.style.color = '#dc3545';
                    }
                });
            }

            updateTimers();
            setInterval(updateTimers, 1000);
        }
    </script>
</body>
</html>


