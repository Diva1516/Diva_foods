package com.food.servlet;

import java.io.IOException;
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
 * OrderHistoryServlet fetches all past orders for the logged-in customer.
 * Straightforward and easy for freshers.
 */
@WebServlet("/orderHistory")
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        // Redirect to login if session has expired
        if (user == null) {
            resp.sendRedirect("login.jsp?redirect=orderHistory");
            return;
        }

        // Fetch user's orders
        OrderDAOImpl orderDAO = new OrderDAOImpl();
        RestaurantDAOImpl restDAO = new RestaurantDAOImpl();
        List<Order> orderList = orderDAO.getOrdersByUser(user.getUserID());
        
        // Auto-update delivered status if time elapsed > ETA (For simulation realism)
        long now = System.currentTimeMillis();
        for (Order o : orderList) {
            if ("Pending".equalsIgnoreCase(o.getStatus()) || "out_for_delivery".equalsIgnoreCase(o.getStatus())) {
                if (o.getOrderDate() != null) {
                    Restaurant rest = restDAO.getRestaurant(o.getRestaurantID());
                    int etaMins = (rest != null) ? rest.getDeliveryTime() : 30;
                    long elapsedMs = now - o.getOrderDate().getTime();
                    long etaMs = etaMins * 60 * 1000L;
                    if (elapsedMs > etaMs) {
                        orderDAO.updateOrderStatus(o.getOrderID(), "Delivered");
                        o.setStatus("Delivered"); // update memory so JSP reflects it immediately
                    }
                }
            }
        }

        req.setAttribute("orderList", orderList);
        req.getRequestDispatcher("order-history.jsp").forward(req, resp);
    }
}
