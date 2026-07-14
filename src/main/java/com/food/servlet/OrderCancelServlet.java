package com.food.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.DAOimpl.RestaurantDAOImpl;
import com.food.model.Order;
import com.food.model.Restaurant;
import com.food.model.User;

@WebServlet("/cancelOrderServlet")
public class OrderCancelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private OrderDAOImpl orderDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            out.print("{\"status\":\"error\", \"message\":\"User not logged in.\"}");
            out.flush();
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String reason = req.getParameter("reason");

            Order order = orderDAO.getOrder(orderId);

            if (order == null) {
                out.print("{\"status\":\"error\", \"message\":\"Order not found.\"}");
                out.flush();
                return;
            }

            if (order.getUserID() != user.getUserID()) {
                out.print("{\"status\":\"error\", \"message\":\"Unauthorized action.\"}");
                out.flush();
                return;
            }

            long currentTime = System.currentTimeMillis();
            long orderTime = order.getOrderDate().getTime();
            
            RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();
            Restaurant rest = restaurantDAO.getRestaurant(order.getRestaurantID());
            int etaMins = (rest != null) ? rest.getDeliveryTime() : 30;
            
            long targetTime = orderTime + (etaMins * 60 * 1000L);
            long elapsedMins = (currentTime - orderTime) / (1000 * 60);

            if (elapsedMins >= 15) {
                out.print("{\"status\":\"error\", \"message\":\"Order has already been Shipped or Processed and can no longer be cancelled.\"}");
                out.flush();
                return;
            }

            if ("Cancelled".equalsIgnoreCase(order.getStatus()) || "Delivered".equalsIgnoreCase(order.getStatus())) {
                out.print("{\"status\":\"error\", \"message\":\"Order is already " + order.getStatus() + ".\"}");
                out.flush();
                return;
            }

            // Update order status
            order.setStatus("Cancelled");
            orderDAO.updateOrder(order);
            
            // Optionally we could store the reason in a new DB table or log it, but the prompt just said "ask reason why".
            System.out.println("Order " + orderId + " cancelled for reason: " + reason);

            out.print("{\"status\":\"success\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"An unexpected error occurred.\"}");
        } finally {
            out.flush();
        }
    }
}
