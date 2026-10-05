# Built by .github/workflows/deploy.yml and pushed to Artifact Registry.
#
# Adapted from the generator's src/main/docker/Dockerfile.jvm (kept as is for
# reference). Deviations, and why:
#   - multi-stage: the image builds the app itself (the stock file expects a
#     `./mvnw package` already run on the host), so `docker compose build` is
#     the whole build.
#   - eclipse-temurin:21-jre instead of ubi9/openjdk-21-runtime and its
#     run-java.sh: a plain `java -jar`, same JVM-mode fast-jar layout.
#   - the port comes from $PORT at RUNTIME (application.properties:
#     quarkus.http.port=${PORT:8080}), never baked in.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

FROM eclipse-temurin:21-jre AS runtime
ARG BUILD_ID=""
WORKDIR /deployments
ENV PORT=8080 BUILD_ID=$BUILD_ID LANGUAGE='en_US:en'
RUN useradd -r -u 10001 app
COPY --from=build --chown=app /src/target/quarkus-app/lib/ /deployments/lib/
COPY --from=build --chown=app /src/target/quarkus-app/*.jar /deployments/
COPY --from=build --chown=app /src/target/quarkus-app/app/ /deployments/app/
COPY --from=build --chown=app /src/target/quarkus-app/quarkus/ /deployments/quarkus/
USER app
EXPOSE 8080
ENTRYPOINT ["java", "-Djava.util.logging.manager=org.jboss.logmanager.LogManager", "-jar", "/deployments/quarkus-run.jar"]
