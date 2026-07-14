package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.RestaurantDAOImpl;
import com.food.model.Restaurant;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * AdminRestaurantServlet handles listing all restaurants, approving or disabling them.
 */
@WebServlet("/admin/restaurants")
public class AdminRestaurantServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
        List<Restaurant> restaurantList = restaurantDAO.getAllRestaurants();

        req.setAttribute("restaurantList", restaurantList);
        req.getRequestDispatcher("/admin/restaurants.jsp").forward(req, resp);
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
        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();

        try {
            if ("toggleStatus".equals(action)) {
                int restaurantId = Integer.parseInt(req.getParameter("restaurantId"));
                Restaurant restaurant = restaurantDAO.getRestaurant(restaurantId);
                
                if (restaurant != null) {
                    // Toggle active status
                    restaurant.setActive(!restaurant.isActive());
                    restaurantDAO.updateRestaurant(restaurant);
                }
            } else if ("delete".equals(action)) {
                int restaurantId = Integer.parseInt(req.getParameter("restaurantId"));
                restaurantDAO.deleteRestaurant(restaurantId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect("restaurants");
    }
}
