package com.food.utility;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Local fallback credentials (used when running in Eclipse)
    private static final String LOCAL_URL = "jdbc:mysql://localhost:3306/diva_foods";
    private static final String LOCAL_USERNAME = "root";
    private static final String LOCAL_PASSWORD = "Diva2004!";

    static Connection connection;

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Check for cloud environment variables (Railway, etc.)
            String envUrl = System.getenv("MYSQL_URL");
            String envUser = System.getenv("MYSQL_USER");
            String envPass = System.getenv("MYSQL_PASSWORD");

            String url;
            String user;
            String pass;

            if (envUrl != null && !envUrl.isEmpty()) {
                // Running on Railway - use cloud database
                // Railway provides mysql:// but JDBC requires jdbc:mysql://
                if (envUrl.startsWith("mysql://")) {
                    // Convert mysql://user:pass@host:port/db to jdbc:mysql://host:port/db
                    // We strip out the credentials from the URL because we pass them explicitly
                    String cleanUrl = envUrl.substring(envUrl.indexOf("@") + 1);
                    url = "jdbc:mysql://" + cleanUrl;
                } else if (!envUrl.startsWith("jdbc:")) {
                    url = "jdbc:" + envUrl;
                } else {
                    url = envUrl;
                }
                user = envUser;
                pass = envPass;
            } else {
                // Running locally - use localhost
                url = LOCAL_URL;
                user = LOCAL_USERNAME;
                pass = LOCAL_PASSWORD;
            }

            connection = DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }
}

