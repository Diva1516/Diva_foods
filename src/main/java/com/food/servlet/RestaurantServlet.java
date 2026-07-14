package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.RestaurantDAOImpl;
import com.food.model.Restaurant;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/callRestaurantServlet")
public class RestaurantServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        RestaurantDAOImpl restaurantDAOImpl = new RestaurantDAOImpl();
        List<Restaurant> allRestaurants = restaurantDAOImpl.getAllRestaurants();
        
        req.setAttribute("allRestaurants", allRestaurants);
        RequestDispatcher rd = req.getRequestDispatcher("restaurants.jsp");
        rd.forward(req, resp);
    }
}
