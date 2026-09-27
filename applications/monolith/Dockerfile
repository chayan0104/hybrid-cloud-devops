FROM maven:3.9.15-eclipse-temurin-25 AS build

WORKDIR /workspace

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk25-temurin

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /workspace/target/monolith.war /usr/local/tomcat/webapps/monolith.war

EXPOSE 8080