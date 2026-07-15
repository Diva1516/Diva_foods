<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - Diva Foods</title>
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>
    <main class="auth-page white-theme">
        <!-- Animated White Background Image -->
        <div class="auth-bg-white-animated"></div>

        <div class="auth-card glass-light">
            <div class="auth-header">
                <h1 class="brand-text" style="font-size: 2.5rem; margin-bottom: 15px; display: inline-block;">Diva Foods</h1>
                <p>Register to order food in minutes</p>
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

            <!-- Form submitting to RegisterServlet -->
            <form id="registerForm" action="callRegisterServlet" method="POST">
                <div class="form-group">
                    <label for="name">Username</label>
                    <input type="text" id="name" name="name" placeholder="Choose a username" required>
                </div>
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="Enter your email" required>
                </div>
                <div class="form-group">
                    <label for="phoneNumber">Phone Number</label>
                    <input type="tel" id="phoneNumber" name="phoneNumber" placeholder="Enter 10-digit phone number" required pattern="[0-9]{10}">
                </div>
                <div class="form-group" style="position: relative;">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Create a password" required minlength="6" style="padding-right: 45px;">
                    <span class="password-toggle" onclick="togglePasswordVisibility('password', this)" style="position: absolute; right: 15px; top: 43px; cursor: pointer; color: rgba(255,255,255,0.7); display: flex; align-items: center; justify-content: center; width: 24px; height: 24px; user-select: none;">
                        <svg class="eye-open" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        <svg class="eye-closed" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display: none;"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                    </span>
                </div>
                <div class="form-group" style="position: relative;">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm your password" required minlength="6" style="padding-right: 45px;">
                    <span class="password-toggle" onclick="togglePasswordVisibility('confirmPassword', this)" style="position: absolute; right: 15px; top: 43px; cursor: pointer; color: rgba(255,255,255,0.7); display: flex; align-items: center; justify-content: center; width: 24px; height: 24px; user-select: none;">
                        <svg class="eye-open" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        <svg class="eye-closed" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display: none;"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                    </span>
                    <small id="passwordError" style="color: #ff4b4b; display: none; margin-top: 5px; font-weight: 600;">Passwords do not match!</small>
                </div>
                <div class="form-group">
                    <label for="role">User Role</label>
                    <select id="role" name="role" required>
                        <option value="" disabled selected>Select your role...</option>
                        <option value="customer">Customer</option>
                        <option value="restaurant_owner">Restaurant Owner</option>
                        <option value="delivery">Delivery Agent</option>
                        <option value="admin">System Admin</option>
                    </select>
                </div>
                <div class="form-group" id="addressGroup" style="display: none;">
                    <label for="address">Delivery Address</label>
                    <textarea id="address" name="address" placeholder="Enter default delivery address in Bangalore" rows="3" required></textarea>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Create Account</button>
            </form>
            <div class="auth-footer">
                Already have an account? <a href="login.jsp">Sign In</a>
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

        document.addEventListener("DOMContentLoaded", function() {
            var roleSelect = document.getElementById("role");
            var addressGroup = document.getElementById("addressGroup");
            var addressTextarea = document.getElementById("address");
            
            var registerForm = document.getElementById("registerForm");
            var password = document.getElementById("password");
            var confirmPassword = document.getElementById("confirmPassword");
            var passwordError = document.getElementById("passwordError");

            function toggleAddressVisibility() {
                if (roleSelect.value === "customer") {
                    addressGroup.style.display = "block";
                    addressTextarea.required = true;
                } else {
                    addressGroup.style.display = "none";
                    addressTextarea.required = false;
                    addressTextarea.value = ""; // clear value so address isn't submitted
                }
            }

            roleSelect.addEventListener("change", toggleAddressVisibility);
            // Run on load to set initial state
            toggleAddressVisibility();

            // Validate passwords match on submit
            registerForm.addEventListener("submit", function(event) {
                if (password.value !== confirmPassword.value) {
                    event.preventDefault(); // Prevent form submission
                    passwordError.style.display = "block";
                } else {
                    passwordError.style.display = "none";
                }
            });

            // Hide error when user types
            confirmPassword.addEventListener("input", function() {
                passwordError.style.display = "none";
            });
            password.addEventListener("input", function() {
                passwordError.style.display = "none";
            });
        });
    </script>
</body>
</html>
