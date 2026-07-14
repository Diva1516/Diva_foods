package com.food.servlet;

import java.io.IOException;
import java.util.List;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.model.Order;
import com.food.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * AdminOrderServlet handles listing all orders placed on the platform
 * and modifying their statuses.
 */
@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Auth Check
        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            resp.sendRedirect("../login.jsp");
            return;
        }

        OrderDAOImpl orderDAO = new OrderDAOImpl();
        List<Order> orderList = orderDAO.getAllOrders();

        req.setAttribute("orderList", orderList);
        req.getRequestDispatcher("/admin/orders.jsp").forward(req, resp);
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

        resp.sendRedirect("orders");
    }
}
