package com.food.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.DAOimpl.RestaurantDAOImpl;
import com.food.DAOimpl.UserDAOImpl;
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
 * DeliveryServlet manages delivery jobs: available, active, and completed.
 */
@WebServlet("/delivery/dashboard")
public class DeliveryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"delivery".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        OrderDAOImpl orderDAO = new OrderDAOImpl();
        RestaurantDAOImpl restaurantDAO = new RestaurantDAOImpl();

        List<Order> availableJobs = orderDAO.getPendingOrders();
        List<Order> agentOrders = orderDAO.getOrdersByDeliveryAgent(currentUser.getUserID());
        
        List<Order> activeJobs = new ArrayList<>();
        int completedJobsCount = 0;
        double earnings = currentUser.getTotalEarnings();

        // Pass ETAs to the UI for active jobs so the timer works
        java.util.Map<Integer, Integer> orderEtas = new java.util.HashMap<>();
        java.util.Map<Integer, Long> orderTimes = new java.util.HashMap<>();

        for (Order o : agentOrders) {
            if ("out_for_delivery".equalsIgnoreCase(o.getStatus())) {
                activeJobs.add(o);
                Restaurant rest = restaurantDAO.getRestaurant(o.getRestaurantID());
                int eta = (rest != null) ? rest.getDeliveryTime() : 30;
                orderEtas.put(o.getOrderID(), eta);
                orderTimes.put(o.getOrderID(), o.getOrderDate().getTime());
            } else if ("Delivered".equalsIgnoreCase(o.getStatus())) {
                completedJobsCount++;
            }
        }

        req.setAttribute("availableJobs", availableJobs);
        req.setAttribute("activeJobs", activeJobs);
        req.setAttribute("orderEtas", orderEtas);
        req.setAttribute("orderTimes", orderTimes);
        req.setAttribute("completedCount", completedJobsCount);
        req.setAttribute("earnings", earnings);

        req.getRequestDispatcher("/delivery/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"delivery".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        String action = req.getParameter("action");
        OrderDAOImpl orderDAO = new OrderDAOImpl();

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            Order order = orderDAO.getOrder(orderId);

            if (order != null) {
                if ("accept".equals(action)) {
                    order.setStatus("out_for_delivery");
                    order.setDeliveryAgentId(currentUser.getUserID());
                    orderDAO.updateOrder(order);
                } else if ("complete".equals(action) && order.getDeliveryAgentId() != null && order.getDeliveryAgentId() == currentUser.getUserID()) {
                    order.setStatus("Delivered");
                    orderDAO.updateOrder(order);
                    
                    // Add earnings to agent
                    currentUser.setTotalEarnings(currentUser.getTotalEarnings() + 40.0);
                    UserDAOImpl userDAO = new UserDAOImpl();
                    userDAO.updateUser(currentUser);
                    session.setAttribute("user", currentUser); // update session
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.sendRedirect("dashboard");
    }
}
