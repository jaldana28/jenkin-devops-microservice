FROM openjdk:8-jdk-alpine
VOLUME /tmp
EXPOSE 8000
COPY /var/jenkins_home/workspace/enkin-devops-microservice_master/target/currency-exchange.jar .
ADD currency-exchange.jar app.jar
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]
