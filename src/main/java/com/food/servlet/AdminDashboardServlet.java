package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.DAOimpl.RestaurantDAOImpl;
import com.food.DAOimpl.UserDAOImpl;
import com.food.model.Order;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * AdminDashboardServlet loads overall platform statistics from the database
 * and forwards to the admin dashboard JSP.
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth check: Make sure user is logged in and has 'admin' role
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        // Initialize DAOs to fetch statistics
        UserDAOImpl userDAO = new UserDAOImpl();
        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
        OrderDAOImpl orderDAO = new OrderDAOImpl();

        try {
            int totalUsers = userDAO.getAllUser().size();
            int totalRestaurants = restaurantDAO.getAllRestaurants().size();
            
            List<Order> orders = orderDAO.getAllOrders();
            int totalOrders = orders.size();
            double totalRevenue = 0.0;
            
            for (Order o : orders) {
                totalRevenue += o.getTotalAmount();
            }

            // Set stats in request attributes
            req.setAttribute("totalUsers", totalUsers);
            req.setAttribute("totalRestaurants", totalRestaurants);
            req.setAttribute("totalOrders", totalOrders);
            req.setAttribute("totalRevenue", totalRevenue);
            req.setAttribute("recentOrders", orders.subList(0, Math.min(orders.size(), 5))); // Top 5 recent orders
            req.setAttribute("allOrders", orders); // All orders for charting
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }
}
