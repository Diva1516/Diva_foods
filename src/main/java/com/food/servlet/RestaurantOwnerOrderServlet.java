package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.model.Order;
import com.food.model.Restaurant;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * RestaurantOwnerOrderServlet manages listing order history and updating order status.
 */
@WebServlet("/restaurant-owner/orders")
public class RestaurantOwnerOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        Restaurant myRestaurant = (Restaurant) session.getAttribute("myRestaurant");

        // Auth Check
        if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        if (myRestaurant == null) {
            resp.sendRedirect("dashboard");
            return;
        }

        // Populate myRestaurants for the sidebar dropdown
        com.food.DAOimpl.RestaurantDAOImpl restaurantDAO = new com.food.DAOimpl.RestaurantDAOImpl();
        List<Restaurant> allRestaurants = restaurantDAO.getAllRestaurants();
        List<Restaurant> myRestaurants = new java.util.ArrayList<>();
        for (Restaurant r : allRestaurants) {
            if (r.getAdminUserID() == currentUser.getUserID()) {
                myRestaurants.add(r);
            }
        }
        req.setAttribute("myRestaurants", myRestaurants);

        OrderDAOImpl orderDAO = new OrderDAOImpl();
        List<Order> orderList = orderDAO.getOrdersByRestaurant(myRestaurant.getRestaurantID());
        req.setAttribute("orderList", orderList);

        req.getRequestDispatcher("/restaurant-owner/orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        String action = req.getParameter("action");
        OrderDAOImpl orderDAO = new OrderDAOImpl();

        try {
            if ("updateStatus".equals(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String newStatus = req.getParameter("status");

                Order order = orderDAO.getOrder(orderId);
                if (order != null) {
                    order.setStatus(newStatus);
                    orderDAO.updateOrder(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Redirect back to dashboard or orders list depending on origin
        String referer = req.getHeader("referer");
        if (referer != null && referer.contains("dashboard")) {
            resp.sendRedirect("dashboard");
        } else {
            resp.sendRedirect("orders");
        }
    }
}
