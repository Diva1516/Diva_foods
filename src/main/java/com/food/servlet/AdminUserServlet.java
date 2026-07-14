package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.UserDAOImpl;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * AdminUserServlet handles listing all users, modifying roles, and deleting users.
 */
@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        UserDAOImpl userDAO = new UserDAOImpl();
        List<User> userList = userDAO.getAllUser();

        req.setAttribute("userList", userList);
        req.getRequestDispatcher("/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        String action = req.getParameter("action");
        UserDAOImpl userDAO = new UserDAOImpl();

        try {
            if ("updateRole".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                String newRole = req.getParameter("role");
                
                User userToUpdate = userDAO.getUser(userId);
                if (userToUpdate != null) {
                    userToUpdate.setRole(newRole);
                    userDAO.updateUser(userToUpdate);
                }
            } else if ("delete".equals(action)) {
                int userId = Integer.parseInt(req.getParameter("userId"));
                userDAO.deleteUser(userId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Redirect back to list
        resp.sendRedirect("users");
    }
}
