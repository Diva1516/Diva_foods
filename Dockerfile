# Use official Tomcat 10.1 with Java 21 (matches your Eclipse setup)
FROM tomcat:10.1-jdk21-temurin

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Create the application directory structure
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes
RUN mkdir -p /app/build/classes

# Copy the web application files (JSP, CSS, JS, images, etc.)
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

# Copy Java source code and compile it inside Docker
COPY src/main/java/ /app/src/main/java/
# Find all .java files and compile them into /app/build/classes
RUN find /app/src/main/java -name "*.java" > sources.txt && \
    javac -cp "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*" -d /app/build/classes @sources.txt

# Copy the newly compiled classes to Tomcat
RUN cp -r /app/build/classes/* /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/

# Expose port 8080 (Railway will auto-detect this)
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
