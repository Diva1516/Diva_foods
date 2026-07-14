<div align="center">
  <img src="src/main/webapp/images/logo.png" alt="Diva Foods Logo" width="150"/>
  <h1>🍽️ Diva Foods</h1>
  <p><strong>A Modern, Multi-Role Food Delivery Platform</strong></p>
  
  <p>
    <img src="https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java" />
    <img src="https://img.shields.io/badge/Apache_Tomcat-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black" alt="Tomcat" />
    <img src="https://img.shields.io/badge/MySQL-00000F?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
    <img src="https://img.shields.io/badge/JSP-007396?style=for-the-badge&logo=java&logoColor=white" alt="JSP" />
    <img src="https://img.shields.io/badge/HTML5_&_CSS3-E34F26?style=for-the-badge&logo=html5&logoColor=white" alt="HTML/CSS" />
  </p>
</div>

---

## 📖 About The Project

**Diva Foods** is a comprehensive, enterprise-level food delivery web application built using Java Servlets, JSP, and MySQL. It features a robust multi-role architecture designed to serve Customers, Restaurant Owners, Delivery Agents, and System Administrators seamlessly within a single unified platform. 

The application goes beyond standard CRUD operations by implementing real-time cart management, secure password hashing (BCrypt), dynamic dashboards, and a sleek, modern UI built from scratch with responsive CSS and vanilla JavaScript.

### 🌟 Key Features

*   **🔒 Secure Authentication:** BCrypt password hashing and robust session management across all user roles.
*   **🛒 Interactive Cart System:** AJAX-powered shopping cart for real-time quantity updates without page reloads.
*   **💳 Secure Checkout Flow:** End-to-end checkout processing with detailed order histories and dynamic 15-minute cancellation policies.
*   **📱 Responsive & Modern UI:** A premium, glassmorphism-inspired design with smooth micro-animations.

---

## 👥 Multi-Role Architecture

The platform supports four distinct user roles, each with custom dashboards and capabilities:

### 1. 🧑‍🍳 Customer
*   Browse a wide selection of restaurants and menus.
*   Add dishes to a dynamic cart and proceed to secure checkout.
*   Track order status and view detailed order history.
*   Manage profile details including delivery addresses and secure passwords.

### 2. 🏪 Restaurant Owner
*   Access a dedicated analytics dashboard to track revenue and orders.
*   Manage restaurant menus (Add, Update, Remove dishes).
*   Toggle availability status for menu items in real-time.
*   View incoming orders assigned specifically to their restaurant.

### 3. 🛵 Delivery Agent
*   Dedicated dashboard to view and accept pending deliveries.
*   Track total earnings and delivery ratings.
*   Manage contact details (phone numbers) directly from the profile.

### 4. 👑 Administrator
*   God-view dashboard monitoring platform health.
*   Manage all users, restaurants, and overall system orders.
*   Enforce quality control across the platform.

---

## 🛠️ Technology Stack

*   **Backend:** Java 11+, Jakarta EE (Servlets & JSP)
*   **Frontend:** HTML5, CSS3, Vanilla JavaScript
*   **Database:** MySQL 8.0+
*   **Server:** Apache Tomcat 10.1+
*   **Security:** `jBCrypt` for password hashing
*   **Architecture:** MVC (Model-View-Controller) Pattern with DAO (Data Access Object) implementations.

---

## 🚀 Getting Started

To run this project locally, follow these steps:

### Prerequisites
*   [Java Development Kit (JDK) 11+](https://adoptium.net/)
*   [Apache Tomcat 10+](https://tomcat.apache.org/)
*   [MySQL Server](https://dev.mysql.com/downloads/)
*   An IDE like Eclipse IDE for Enterprise Java or IntelliJ IDEA.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Diva1516/Diva_foods.git
   ```

2. **Database Setup**
   * Create a new MySQL database named `diva_foods`.
   * Import the provided `.sql` files to generate the tables and populate the initial seed data.
   * Update the database credentials in `src/main/java/com/food/utility/DBConnection.java` (username and password).

3. **Deploy to Tomcat**
   * Import the project into your IDE as a Dynamic Web Project.
   * Add the required `.jar` files (MySQL Connector, jBCrypt) to `src/main/webapp/WEB-INF/lib`.
   * Add the project to your Apache Tomcat Server instance and start the server.

4. **Access the Application**
   * Open your browser and navigate to: `http://localhost:8080/Diva_Foods/`

---

## 📸 Application Screenshots

*(Screenshots can be added here to showcase the stunning UI!)*

---

<div align="center">
  <p>Built with ❤️ for a seamless food delivery experience.</p>
</div>
