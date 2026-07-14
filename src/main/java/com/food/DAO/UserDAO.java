package com.food.DAO;

import java.util.List;
import com.food.model.User;

public interface UserDAO {
    int addUser(User user);
    User getUser(int userId);
    User getUserByEmail(String email);
    User getUserByUsername(String username);
    void updateUser(User user);
    void deleteUser(int userId);
    List<User> getAllUser();
}
