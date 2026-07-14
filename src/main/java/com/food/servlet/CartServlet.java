package com.food.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import com.food.DAOimpl.MenuDAOImpl;
import com.food.model.Cart;
import com.food.model.CartItem;
import com.food.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cartServlet")
public class CartServlet extends HttpServlet {

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        
        com.food.model.User sessionUser = (com.food.model.User) session.getAttribute("user");
        if (sessionUser != null && !"customer".equalsIgnoreCase(sessionUser.getRole())) {
            if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
                resp.setContentType("application/json");
                PrintWriter out = resp.getWriter();
                out.print("{\"status\":\"error\",\"message\":\"Staff accounts cannot place orders.\"}");
                out.flush();
            } else {
                resp.sendRedirect("index.jsp");
            }
            return;
        }

        Cart cart = (Cart) session.getAttribute("cart");

        int newRestaurantId = 0;
        String restIdParam = req.getParameter("restaurantId");
        if (restIdParam != null && !restIdParam.isEmpty()) {
            newRestaurantId = Integer.parseInt(restIdParam);
        }

        Integer currentRestaurantId = (Integer) session.getAttribute("restaurantId");

        boolean isConflict = false;
        String forceParam = req.getParameter("force");
        boolean force = "true".equals(forceParam);

        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }

        if (newRestaurantId != 0) {
            if (!cart.isEmpty() && currentRestaurantId != null && currentRestaurantId != newRestaurantId) {
                if (!force && !"clear".equals(req.getParameter("action"))) {
                    isConflict = true;
                } else {
                    cart.clearCart();
                    session.setAttribute("restaurantId", newRestaurantId);
                }
            } else {
                session.setAttribute("restaurantId", newRestaurantId);
            }
        }

        String action = req.getParameter("action");

        if (!isConflict) {
            if ("add".equals(action)) {
                addItemToCart(req, cart);
            } else if ("update".equals(action)) {
                updateItemInCart(req, cart);
            } else if ("delete".equals(action)) {
                deleteItemFromCart(req, cart);
            } else if ("clear".equals(action)) {
                cart.clearCart();
                session.removeAttribute("cart");
                session.removeAttribute("restaurantId");
            }
            session.setAttribute("cart", cart);
        }

        // Check if this is an AJAX request
        String ajaxParam = req.getParameter("ajax");
        if ("true".equals(ajaxParam)) {
            // Return JSON response for AJAX calls
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();

            if (isConflict) {
                out.print("{\"status\":\"conflict\",\"message\":\"Your cart contains items from another restaurant. Do you want to discard your selection and add dishes from this restaurant?\"}");
                out.flush();
                return;
            }

            double subtotal = cart.getTotalPrice();
            double deliveryFee = 40.00;
            double gst = subtotal * 0.05;
            double total = subtotal + deliveryFee + gst;
            int itemCount = cart.getItemCount();

            // Build JSON manually (no external library needed)
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"status\":\"success\",");
            json.append("\"itemCount\":").append(itemCount).append(",");
            json.append("\"subtotal\":").append(String.format(java.util.Locale.US, "%.2f", subtotal)).append(",");
            json.append("\"deliveryFee\":").append(String.format(java.util.Locale.US, "%.2f", deliveryFee)).append(",");
            json.append("\"gst\":").append(String.format(java.util.Locale.US, "%.2f", gst)).append(",");
            json.append("\"total\":").append(String.format(java.util.Locale.US, "%.2f", total)).append(",");

            // Include items array for cart page updates
            json.append("\"items\":[");
            boolean first = true;
            for (CartItem ci : cart.getItems().values()) {
                if (!first) json.append(",");
                json.append("{");
                json.append("\"menuId\":").append(ci.getMenuId()).append(",");
                json.append("\"restaurantId\":").append(ci.getRestaurantId()).append(",");
                json.append("\"name\":\"").append(ci.getName().replace("\"", "\\\"")).append("\",");
                json.append("\"price\":").append(String.format(java.util.Locale.US, "%.2f", ci.getPrice())).append(",");
                json.append("\"quantity\":").append(ci.getQuantity()).append(",");
                json.append("\"totalPrice\":").append(String.format(java.util.Locale.US, "%.2f", ci.getTotalPrice())).append(",");
                json.append("\"imagePath\":\"").append(ci.getImagePath() != null ? ci.getImagePath() : "images/biryani.png").append("\"");
                json.append("}");
                first = false;
            }
            json.append("]");
            json.append("}");

            out.print(json.toString());
            out.flush();
            return;
        }

        // Non-AJAX: redirect normally
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            resp.sendRedirect(redirect);
        } else {
            resp.sendRedirect("menu?restaurantID=" + newRestaurantId);
        }
    }

    private void addItemToCart(HttpServletRequest req, Cart cart) {
        int menuId = Integer.parseInt(req.getParameter("menuId"));
        int quantity = 1;
        String qtyParam = req.getParameter("quantity");
        if (qtyParam != null && !qtyParam.isEmpty()) {
            quantity = Integer.parseInt(qtyParam);
        }

        MenuDAOImpl menuDAOImpl = new MenuDAOImpl();
        Menu menu = menuDAOImpl.getMenu(menuId);

        if (menu != null) {
            CartItem cartItem = new CartItem(
                menu.getMenuID(),
                menu.getRestaurantID(),
                menu.getItemName(),
                menu.getPrice(),
                quantity,
                menu.getImagePath()
            );
            cart.addItem(cartItem);
        }
    }

    private void updateItemInCart(HttpServletRequest req, Cart cart) {
        int menuId = Integer.parseInt(req.getParameter("menuId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));
        cart.updateItem(menuId, quantity);
    }

    private void deleteItemFromCart(HttpServletRequest req, Cart cart) {
        int menuId = Integer.parseInt(req.getParameter("menuId"));
        cart.removeItem(menuId);
    }
}
