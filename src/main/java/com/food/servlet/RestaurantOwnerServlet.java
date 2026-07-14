package com.food.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.DAOimpl.RestaurantDAOImpl;
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
 * RestaurantOwnerServlet loads statistics and active orders for the owner's restaurant.
 */
@WebServlet("/restaurant-owner/dashboard")
public class RestaurantOwnerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
        Restaurant myRestaurant = null;

        List<Restaurant> myRestaurants = new ArrayList<>();
        List<Restaurant> allRestaurants = restaurantDAO.getAllRestaurants();
        for (Restaurant r : allRestaurants) {
            if (r.getAdminUserID() == currentUser.getUserID()) {
                myRestaurants.add(r);
            }
        }
        req.setAttribute("myRestaurants", myRestaurants);

        String switchId = req.getParameter("switchRestaurantId");
        if (switchId != null && !switchId.isEmpty()) {
            int id = Integer.parseInt(switchId);
            for (Restaurant r : myRestaurants) {
                if (r.getRestaurantID() == id) {
                    myRestaurant = r;
                    break;
                }
            }
        } else if (!myRestaurants.isEmpty()) {
            // Default to the one already in session, or the first one
            Restaurant sessionRest = (Restaurant) session.getAttribute("myRestaurant");
            if (sessionRest != null) {
                boolean found = false;
                for (Restaurant r : myRestaurants) {
                    if (r.getRestaurantID() == sessionRest.getRestaurantID()) {
                        myRestaurant = r;
                        found = true; break;
                    }
                }
                if (!found) myRestaurant = myRestaurants.get(0);
            } else {
                myRestaurant = myRestaurants.get(0);
            }
        }

        if (myRestaurant != null) {
            session.setAttribute("myRestaurant", myRestaurant); // Save in session for other owner servlets
            
            OrderDAOImpl orderDAO = new OrderDAOImpl();
            List<Order> allOrders = orderDAO.getOrdersByRestaurant(myRestaurant.getRestaurantID());

            // Calculate simple stats
            int pendingOrders = 0;
            double revenue = 0.0;
            List<Order> activeOrders = new ArrayList<>();

            for (Order o : allOrders) {
                if ("Pending".equalsIgnoreCase(o.getStatus()) || "Preparing".equalsIgnoreCase(o.getStatus()) || "Ready".equalsIgnoreCase(o.getStatus())) {
                    pendingOrders++;
                    activeOrders.add(o);
                }
                if ("Delivered".equalsIgnoreCase(o.getStatus())) {
                    revenue += o.getTotalAmount();
                }
            }

            req.setAttribute("pendingOrdersCount", pendingOrders);
            req.setAttribute("totalOrdersCount", allOrders.size());
            req.setAttribute("revenue", revenue);
            req.setAttribute("activeOrders", activeOrders);
        }

        req.getRequestDispatcher("/restaurant-owner/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"restaurant_owner".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if ("registerRestaurant".equals(action)) {
            String name = req.getParameter("name");
            String cuisineType = req.getParameter("cuisineType");
            int deliveryTime = Integer.parseInt(req.getParameter("deliveryTime"));
            String address = req.getParameter("address");

            Restaurant newRest = new Restaurant(name, cuisineType, deliveryTime, address, currentUser.getUserID(), 4.5, true, "default.jpg");
            RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
            restaurantDAO.addRestaurant(newRest);
        }

        resp.sendRedirect("dashboard");
    }
}
