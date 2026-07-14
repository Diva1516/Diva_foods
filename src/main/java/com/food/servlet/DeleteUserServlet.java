package com.food.servlet;

import java.io.IOException;

import com.food.DAOimpl.UserDAOImpl;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * DeleteUserServlet handles deleting the user's account from the database.
 */
@WebServlet("/deleteUser")
public class DeleteUserServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user != null) {
            UserDAOImpl userDAO = new UserDAOImpl();
            // Delete user from DB
            userDAO.deleteUser(user.getUserID());
            
            // Invalidate session
            session.invalidate();
        }

        // Redirect to register page
        resp.sendRedirect("register.jsp");
    }
}
