FROM maven:3.9.15-eclipse-temurin-25 AS build

WORKDIR /workspace

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:25-jre

WORKDIR /app

COPY --from=build /workspace/target/microservice-1.0.0.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java","-jar","app.jar"]