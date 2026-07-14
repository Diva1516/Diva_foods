package com.food.servlet;

import java.io.IOException;

import com.food.DAOimpl.UserDAOImpl;
import com.food.model.User;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * ProfileServlet handles updating the user's profile information.
 */
@WebServlet("/profileServlet")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        // Redirect to login if session has expired
        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String username = req.getParameter("username");
        String address = req.getParameter("address");
        String phoneNumber = req.getParameter("phoneNumber");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (address == null) {
            address = user.getAddress();
        }

        // Update User object values
        user.setUserName(username);
        user.setAddress(address);
        if (phoneNumber != null && !phoneNumber.trim().isEmpty()) {
            user.setPhoneNumber(phoneNumber);
        }

        // Password change logic
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            if (newPassword.equals(confirmPassword)) {
                String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
                user.setPassword(hashedPassword);
                user.setConfirmPassword(hashedPassword);
            } else {
                req.setAttribute("errorMessage", "Passwords do not match. Profile partially updated.");
            }
        }

        UserDAOImpl userDAOImpl = new UserDAOImpl();
        try {
            userDAOImpl.updateUser(user);
            
            // Save updated User back into the session
            session.setAttribute("user", user);
            req.setAttribute("successMessage", "Profile updated successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMessage", "Error updating profile. Please try again.");
        }

        req.getRequestDispatcher("profile.jsp").forward(req, resp);
    }
}
