package com.food.servlet;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import com.food.DAOimpl.UserDAOImpl;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * LoginServlet handles user authentication, session creation, and role-based routing.
 */
@WebServlet("/callLoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String loginId = req.getParameter("loginId");
        if (loginId == null || loginId.trim().isEmpty()) {
            loginId = req.getParameter("email");
        }
        String password = req.getParameter("password");

        User user = null;
        if (loginId != null && !loginId.trim().isEmpty()) {
            user = findUserByLoginId(loginId.trim());
        }

        // Check if user exists and password matches the BCrypt hash
        if (user != null && BCrypt.checkpw(password, user.getPassword())) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user); // Store entire User object in session

            String role = user.getRole();
            boolean isCustomer = (role == null || "customer".equalsIgnoreCase(role));

            if (!isCustomer) {
                if ("admin".equalsIgnoreCase(role)) {
                    resp.sendRedirect("admin/dashboard");
                } else if ("restaurant_owner".equalsIgnoreCase(role)) {
                    resp.sendRedirect("restaurant-owner/dashboard");
                } else if ("delivery".equalsIgnoreCase(role)) {
                    resp.sendRedirect("delivery/dashboard");
                } else {
                    resp.sendRedirect("index.jsp");
                }
            } else {
                // Customer logic: respect the redirect parameter
                String redirect = req.getParameter("redirect");
                if (redirect != null && !redirect.trim().isEmpty()) {
                    resp.sendRedirect(redirect);
                } else {
                    resp.sendRedirect("callRestaurantServlet");
                }
            }
        } else {
            // Preserve the redirect parameter so it is not lost upon validation error
            req.setAttribute("redirect", req.getParameter("redirect"));
            // Set error message and forward back to login page
            req.setAttribute("errorMessage", "Invalid email, username, phone number, or password!");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }

    private User findUserByLoginId(String loginId) {
        User user = null;
        String sql = "SELECT * FROM user WHERE Email = ? OR Username = ? OR PhoneNumber = ?";
        try (java.sql.Connection conn = com.food.utility.DBConnection.getConnection();
             java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, loginId);
            pstmt.setString(2, loginId);
            pstmt.setString(3, loginId);
            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = com.food.DAOimpl.UserDAOImpl.extractUserFromResultSet(rs);
                }
            }
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
}
