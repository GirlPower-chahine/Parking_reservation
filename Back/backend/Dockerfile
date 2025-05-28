# Stage 1: Build the Spring Boot application
FROM eclipse-temurin:17-jdk-alpine as build

WORKDIR /app

# Définir l'encodage UTF-8
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Copie les fichiers du wrapper Maven et le pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Rendre le wrapper Maven exécutable
RUN chmod +x ./mvnw

# Copie le code source
COPY src src

# Construit l'application avec encodage UTF-8
RUN ./mvnw clean install -Dmaven.test.skip=true -Dfile.encoding=UTF-8

# Stage 2: Create the final lightweight image
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Définir l'encodage UTF-8 pour le runtime
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Copie le JAR construit
COPY --from=build /app/target/*.jar app.jar

# Expose le port
EXPOSE 8080

# Commande d'entrée avec encodage UTF-8
ENTRYPOINT ["java", "-Dfile.encoding=UTF-8", "-jar", "app.jar"]