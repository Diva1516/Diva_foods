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
            String envHost = System.getenv("MYSQLHOST");
            String envPort = System.getenv("MYSQLPORT");
            String envDb = System.getenv("MYSQL_DATABASE");
            String envUser = System.getenv("MYSQLUSER");
            String envPass = System.getenv("MYSQLPASSWORD");

            String url;
            String user;
            String pass;

            if (envHost != null && !envHost.isEmpty()) {
                // Running on Railway - use cloud database variables directly
                url = "jdbc:mysql://" + envHost + ":" + (envPort != null ? envPort : "3306") + "/" + (envDb != null ? envDb : "railway");
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
            throw new RuntimeException("JDBC Driver not found: " + e.getMessage(), e);
        } catch (SQLException e) {
            String debugUrl = "jdbc:mysql://" + System.getenv("MYSQLHOST") + ":" + System.getenv("MYSQLPORT") + "/railway";
            throw new RuntimeException("DB Connection Failed! URL: [" + debugUrl + "] User: [" + System.getenv("MYSQLUSER") + "] Error: " + e.getMessage(), e);
        }
        return connection;
    }
}

