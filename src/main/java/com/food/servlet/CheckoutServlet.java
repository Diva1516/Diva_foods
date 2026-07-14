package com.food.servlet;

import java.io.IOException;
import java.sql.Timestamp;

import com.food.DAOimpl.OrderDAOImpl;
import com.food.DAOimpl.OrderHistoryDAOImpl;
import com.food.DAOimpl.OrderItemDAOImpl;
import com.food.model.Cart;
import com.food.model.CartItem;
import com.food.model.Order;
import com.food.model.OrderHistory;
import com.food.model.OrderItem;
import com.food.model.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        Cart cart = (Cart) session.getAttribute("cart");
        Integer restaurantId = (Integer) session.getAttribute("restaurantId");

        if (user == null) {
            resp.sendRedirect("login.jsp?redirect=checkout.jsp");
            return;
        }

        if (!"customer".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect("index.jsp");
            return;
        }

        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect("cart.jsp");
            return;
        }

        String paymentMode = req.getParameter("paymentMode");
        String deliveryAddress = req.getParameter("deliveryAddress");

        if (deliveryAddress != null && !deliveryAddress.trim().isEmpty() && !deliveryAddress.equals(user.getAddress())) {
            user.setAddress(deliveryAddress.trim());
            new com.food.DAOimpl.UserDAOImpl().updateUser(user);
            session.setAttribute("user", user);
        }

        // Map UI payment modes to database ENUM values
        String dbPaymentMethod = mapPaymentMethod(paymentMode);

        // Calculate order amounts
        double subtotal = cart.getTotalPrice();
        double deliveryFee = 40.00;
        double gst = subtotal * 0.05;
        double finalAmount = subtotal + deliveryFee + gst;

        Timestamp now = new Timestamp(System.currentTimeMillis());

        // Create Order object with correct ENUM values
        Order order = new Order();
        order.setUserID(user.getUserID());
        order.setRestaurantID(restaurantId != null ? restaurantId : 0);
        order.setOrderDate(now);
        order.setPaymentMethod(dbPaymentMethod);
        order.setStatus("pending"); // Lowercase to match DB ENUM
        order.setTotalAmount(finalAmount);

        // Add order to DB and get the auto-generated Order ID
        OrderDAOImpl orderDAOImpl = new OrderDAOImpl();
        int orderId = orderDAOImpl.addOrder(order);

        // Save each item in the cart as a separate OrderItem in the DB
        OrderItemDAOImpl orderItemDAOImpl = new OrderItemDAOImpl();
        for (CartItem cartItem : cart.getItems().values()) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrderID(orderId);
            orderItem.setMenuID(cartItem.getMenuId());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setItemTotal(cartItem.getTotalPrice());
            orderItemDAOImpl.addOrderItem(orderItem);
        }

        // Also save to OrderHistory table for history tracking
        OrderHistoryDAOImpl orderHistoryDAO = new OrderHistoryDAOImpl();
        OrderHistory history = new OrderHistory();
        history.setOrderID(orderId);
        history.setUserID(user.getUserID());
        history.setOrderDate(now);
        history.setTotalAmount(finalAmount);
        history.setStatus("pending");
        orderHistoryDAO.addOrderHistory(history);

        // Clear the cart from session
        session.removeAttribute("cart");
        session.removeAttribute("restaurantId");

        // Set attributes for order confirmation page
        order.setOrderID(orderId);
        req.setAttribute("order", order);
        req.setAttribute("paymentMethod", paymentMode != null ? paymentMode : "UPI");
        req.setAttribute("deliveryAddress", deliveryAddress != null ? deliveryAddress : user.getAddress());

        RequestDispatcher rd = req.getRequestDispatcher("order-confirmation.jsp");
        rd.forward(req, resp);
    }

    /**
     * Maps user-friendly payment mode names to MySQL ENUM values.
     * DB expects: 'cash', 'upi', 'card', 'wallet'
     */
    private String mapPaymentMethod(String paymentMode) {
        if (paymentMode == null) return "upi";
        switch (paymentMode.toUpperCase()) {
            case "COD":
                return "cash";
            case "UPI":
                return "upi";
            case "CARD":
                return "card";
            case "NETBANKING":
            case "WALLET":
                return "wallet";
            default:
                return "upi";
        }
    }
}
