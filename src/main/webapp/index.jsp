<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.food.model.User, com.food.model.Cart" %>
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
    <title>Diva Foods - Bangalore's Premium Food Delivery App</title>
    <link rel="stylesheet" href="css/common.css?v=1.1">
    <link rel="stylesheet" href="css/index.css?v=1.1">
    <script>
        window.DIVA_USER = <%= sessionUser != null ? "{\"name\": \"" + sessionUser.getUserName() + "\", \"role\": \"" + sessionUser.getRole() + "\"}" : "null" %>;
        window.DIVA_CART_COUNT = <%= cartCount %>;
    </script>
</head>
<body>
    <!-- Header Navigation (Injected dynamically) -->
    <header></header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-bg">
            <video id="heroVideo" src="images/hero-video-1.mp4" autoplay muted playsinline class="hero-video" onended="playNextVideo()"></video>
            <script>
                const heroVideos = ['images/hero-video-1.mp4', 'images/hero-video-2.mp4'];
                let currentVideoIndex = 0;
                function playNextVideo() {
                    currentVideoIndex = (currentVideoIndex + 1) % heroVideos.length;
                    const videoEl = document.getElementById('heroVideo');
                    videoEl.src = heroVideos[currentVideoIndex];
                    videoEl.play();
                }
            </script>
        </div>
        <div class="hero-content">
            <div class="hero-badge">🛵 Fastest Delivery in Bangalore</div>
            <h1 class="hero-title">Bangalore's Finest Cuisines, <span class="highlight">Delivered Hot.</span></h1>
            <p class="hero-subtitle">Experience legendary recipes from Vidyarthi Bhavan, Meghana Foods, MTR, and more, delivered straight to your home.</p>
            <div class="hero-actions">
                <a href="callRestaurantServlet" class="btn btn-primary btn-lg">Explore Restaurants</a>
                <a href="login.jsp" class="btn btn-secondary btn-lg">Sign In</a>
            </div>
            <div class="hero-stats">
                <div class="hero-stat">
                    <div class="stat-number">6+</div>
                    <div class="stat-label">Iconic Brands</div>
                </div>
                <div class="hero-stat">
                    <div class="stat-number">20m</div>
                    <div class="stat-label">Avg Delivery</div>
                </div>
                <div class="hero-stat">
                    <div class="stat-number">4.8★</div>
                    <div class="stat-label">User Rating</div>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works Section with Animated Background -->
    <section class="section" style="overflow: hidden; position: relative;">
        <!-- Delicate curved SVG background lines -->
        <svg class="hero-swoosh" viewBox="0 0 1440 400" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0,150 C300,300 400,0 800,150 C1200,300 1300,50 1440,200" fill="none" stroke="#ff4b6b" stroke-width="1.5" stroke-dasharray="10 10"/>
            <path d="M0,250 C200,100 600,400 1000,200 C1300,50 1400,250 1440,150" fill="none" stroke="#ff4b6b" stroke-width="0.8"/>
        </svg>
        
        <!-- Floating Food Emojis as Background -->
        <div class="floating-food ff-1">🍔</div>
        <div class="floating-food ff-2">🍕</div>
        <div class="floating-food ff-3">🥟</div>
        <div class="floating-food ff-4">🍲</div>
        <div class="floating-food ff-5">🍅</div>
        <div class="floating-food ff-6">🌿</div>
        <div class="container">
            <div class="section-header">
                <span class="section-tag">Order Process</span>
                <h2 class="section-title">How It Works</h2>
                <p class="section-subtitle">Three simple steps to satisfy your gourmet cravings in minutes.</p>
            </div>
            <div class="steps-grid">
                <div class="step-card animate-fade-in animate-delay-1">
                    <div class="step-number">1</div>
                    <h3>Choose Restaurant</h3>
                    <p>Select from Bangalore's highly rated culinary landmarks nearby.</p>
                </div>
                <div class="step-card animate-fade-in animate-delay-2">
                    <div class="step-number">2</div>
                    <h3>Select Dishes</h3>
                    <p>Customize your plate from fresh idlis, crispy dosas, or rich biryanis.</p>
                </div>
                <div class="step-card animate-fade-in animate-delay-3">
                    <div class="step-number">3</div>
                    <h3>Fast Delivery</h3>
                    <p>Track your delivery rider in real-time as your meal arrives hot.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer (Injected dynamically) -->
    <footer></footer>

    <!-- Core App JS -->
    <script src="js/app.js"></script>
</body>
</html>
