<%@ page import="com.food.model.User, com.food.model.Cart" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    <title>Login - Diva Foods</title>
    <!-- Fixed stylesheet link -->
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/auth.css">
    <script>
        window.DIVA_USER = <%= sessionUser != null ? "{\"name\": \"" + sessionUser.getUserName() + "\", \"role\": \"" + sessionUser.getRole() + "\"}" : "null" %>;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
</head>
<body>
    <main class="auth-page white-theme">
        <!-- Animated White Background with Floating Foods -->
        <div class="auth-bg-white">
            <img src="images/burger.png" alt="Burger" class="float-food food-1">
            <img src="images/french_fries.png" alt="Fries" class="float-food food-2">
            <img src="images/coke.png" alt="Coke" class="float-food food-3">
            <img src="images/pizza.png" alt="Pizza" class="float-food food-4" onerror="this.src='images/dosa.png'">
        </div>

        <div class="auth-card glass-light">
            <div class="auth-header">
                <h1 class="brand-text" style="font-size: 2.5rem; margin-bottom: 15px; display: inline-block;">Diva Foods</h1>
                <p>Login to your account</p>
            </div>
            
            <!-- Error message container from servlet -->
            <%
                String errorMessage = (String) request.getAttribute("errorMessage");
                if (errorMessage != null) {
            %>
                <div class="error-banner" style="background-color: rgba(255, 75, 75, 0.15); border: 1px solid #ff4b4b; color: #ff4b4b; padding: 10px 14px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; text-align: center;">
                    <%= errorMessage %>
                </div>
            <%
                }
            %>

            <!-- Standard HTML form submitting to LoginServlet -->
            <%
                String redirect = request.getParameter("redirect");
                if (redirect == null) {
                    redirect = (String) request.getAttribute("redirect");
                }
                if (redirect == null) {
                    redirect = "";
                }
            %>
            <form id="loginForm" action="callLoginServlet" method="POST">
                <input type="hidden" name="redirect" value="<%= redirect %>">
                <div class="form-group">
                    <label for="loginId">Email / Username / Phone Number</label>
                    <input type="text" id="loginId" name="loginId" placeholder="Enter email, username or phone number" required autocomplete="username">
                </div>
                <div class="form-group" style="position: relative;">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required autocomplete="current-password" style="padding-right: 45px;">
                    <span class="password-toggle" onclick="togglePasswordVisibility('password', this)" style="position: absolute; right: 15px; top: 43px; cursor: pointer; color: rgba(255,255,255,0.7); display: flex; align-items: center; justify-content: center; width: 24px; height: 24px; user-select: none;">
                        <svg class="eye-open" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        <svg class="eye-closed" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display: none;"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                    </span>
                </div>
                <div class="form-group">
                    <div class="checkbox-row">
                        <label class="checkbox-label">
                            <input type="checkbox" id="rememberMe" name="rememberMe"> Remember Me
                        </label>
                        <a href="#" class="forgot-link">Forgot Password?</a>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Sign In</button>
            </form>
            
            <div class="auth-footer">
                Don't have an account? <a href="register.jsp">Sign Up</a>
            </div>
        </div>
    </main>

    <script src="js/app.js"></script>
    <script>
        function togglePasswordVisibility(inputId, spanEl) {
            var input = document.getElementById(inputId);
            var eyeOpen = spanEl.querySelector(".eye-open");
            var eyeClosed = spanEl.querySelector(".eye-closed");
            if (input.type === "password") {
                input.type = "text";
                eyeOpen.style.display = "none";
                eyeClosed.style.display = "block";
            } else {
                input.type = "password";
                eyeOpen.style.display = "block";
                eyeClosed.style.display = "none";
            }
        }
    </script>
</body>
</html>
