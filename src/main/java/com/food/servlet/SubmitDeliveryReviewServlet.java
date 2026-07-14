package com.food.servlet;

import java.io.IOException;
import com.food.DAOimpl.DeliveryReviewDAOImpl;
import com.food.model.DeliveryReview;
import com.food.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/submitDeliveryReview")
public class SubmitDeliveryReviewServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"customer".equals(currentUser.getRole())) {
            resp.sendRedirect("login.jsp");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            int agentId = Integer.parseInt(req.getParameter("agentId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comments = req.getParameter("comments");
            
            DeliveryReview review = new DeliveryReview(orderId, currentUser.getUserID(), agentId, rating, comments);
            DeliveryReviewDAOImpl reviewDAO = new DeliveryReviewDAOImpl();
            reviewDAO.addReview(review);
            
            // Redirect back to order history with success message
            session.setAttribute("toastMsg", "Review submitted successfully!");
            session.setAttribute("toastType", "success");
            resp.sendRedirect("orderHistory");
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("toastMsg", "Failed to submit review.");
            session.setAttribute("toastType", "error");
            resp.sendRedirect("orderHistory");
        }
    }
}
