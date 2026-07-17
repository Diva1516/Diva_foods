# Use official Tomcat 10.1 with Java 21 (matches your Eclipse setup)
FROM tomcat:10.1-jdk21-temurin

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Create the application directory structure
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Copy the web application files (JSP, CSS, JS, images, etc.)
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

# Copy the compiled Java class files
COPY build/classes/ /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/

# Expose port 8080 (Railway will auto-detect this)
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
