package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.MenuDAOImpl;
import com.food.DAOimpl.RestaurantDAOImpl;
import com.food.model.Menu;
import com.food.model.Restaurant;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * MenuServlet retrieves the details of a restaurant and its menu list,
 * then forwards to the menu page.
 */
@WebServlet("/menu")
public class MenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String restIdParam = req.getParameter("restaurantID");
        if (restIdParam == null || restIdParam.isEmpty()) {
            resp.sendRedirect("callRestaurantServlet");
            return;
        }

        int restaurantId = Integer.parseInt(restIdParam);

        // Fetch restaurant details for the header
        RestaurantDAOImpl restaurantDAOImpl = new RestaurantDAOImpl();
        Restaurant restaurant = restaurantDAOImpl.getRestaurant(restaurantId);

        // Fetch menu items for this restaurant
        MenuDAOImpl menuDAOImpl = new MenuDAOImpl();
        List<Menu> menuList = menuDAOImpl.getMenusByRestaurant(restaurantId);

        req.setAttribute("restaurant", restaurant);
        req.setAttribute("menuList", menuList);

        RequestDispatcher rd = req.getRequestDispatcher("menu.jsp");
        rd.forward(req, resp);
    }
}
