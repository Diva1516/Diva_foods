package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.MenuDAOImpl;
import com.food.model.Menu;
import com.food.model.Restaurant;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * MenuManagementServlet handles listing, adding, and deleting menu items.
 */
@WebServlet("/restaurant-owner/menu")
public class MenuManagementServlet extends HttpServlet {

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

        MenuDAOImpl menuDAO = new MenuDAOImpl();
        List<Menu> menuList = menuDAO.getMenusByRestaurant(myRestaurant.getRestaurantID());
        req.setAttribute("menuList", menuList);

        req.getRequestDispatcher("/restaurant-owner/menu-management.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        String action = req.getParameter("action");
        MenuDAOImpl menuDAO = new MenuDAOImpl();

        try {
            if ("add".equals(action)) {
                String name = req.getParameter("name");
                double price = Double.parseDouble(req.getParameter("price"));
                String description = req.getParameter("description");
                String imagePath = req.getParameter("imagePath");
                if (imagePath == null || imagePath.isEmpty()) {
                    imagePath = "images/biryani.png"; // Default fallback
                }

                Menu menu = new Menu();
                menu.setRestaurantID(myRestaurant.getRestaurantID());
                menu.setItemName(name);
                menu.setPrice(price);
                menu.setDescription(description);
                menu.setAvailable(true);
                menu.setImagePath(imagePath);

                menuDAO.addMenu(menu);
            } else if ("delete".equals(action)) {
                int menuId = Integer.parseInt(req.getParameter("menuId"));
                menuDAO.deleteMenu(menuId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect("menu");
    }
}
