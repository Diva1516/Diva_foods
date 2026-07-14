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

/**
 * RegisterServlet handles new user registration, hashes the password using BCrypt,
 * and saves the user to the database.
 */
@WebServlet("/callRegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String role = req.getParameter("role");
        String address = req.getParameter("address");
        String phoneNumber = req.getParameter("phoneNumber");

        // Address is optional for non-customer roles
        if (!"customer".equals(role)) {
            address = "";
        }

        // Hash the password for security
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(10));
        String confirmPasswordParam = req.getParameter("confirmPassword");
        String hashedConfirmPassword = confirmPasswordParam != null ? BCrypt.hashpw(confirmPasswordParam, BCrypt.gensalt(10)) : "";

        // Create User object with phoneNumber
        User user = new User(name, email, hashedPassword, address, phoneNumber, role);
        user.setConfirmPassword(hashedConfirmPassword);
        user.setTotalEarnings(0.0);
        UserDAOImpl userDAOImpl = new UserDAOImpl();
        
        int result = userDAOImpl.addUser(user);

        if (result == 1) {
            // Successfully registered, go to login
            resp.sendRedirect("login.jsp");
        } else {
            // Failed to register (e.g. duplicate email), show error
            req.setAttribute("errorMessage", "Registration failed! Email may already exist.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }
}
