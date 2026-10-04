# syntax=docker/dockerfile:1.7
# ---------- Stage 1: build the WAR with Maven + JDK 21 ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src
COPY pom.xml .
# Cache dependencies in their own layer so code-only changes build fast
RUN --mount=type=cache,target=/root/.m2 mvn -B -q dependency:go-offline
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -q clean package -DskipTests

# ---------- Stage 2: runtime on Tomcat 9 (javax.servlet) + JDK 21 ----------
FROM tomcat:9.0-jdk21-temurin

ENV CATALINA_HOME=/usr/local/tomcat \
    JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

WORKDIR /usr/local/tomcat

# 1. Remove default apps (manager/examples are an attack surface)
# 2. Trust X-Forwarded-Proto/For from the ALB so request.isSecure()/redirects are correct behind HTTPS
# 3. Run as an unprivileged user
RUN rm -rf webapps/* webapps.dist \
 && sed -i 's#</Host>#  <Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="x-forwarded-for" protocolHeader="x-forwarded-proto" />\n      </Host>#' conf/server.xml \
 && grep -q RemoteIpValve conf/server.xml \
 && groupadd --system --gid 10001 app \
 && useradd --system --uid 10001 --gid app --no-create-home app \
 && chown -R app:app /usr/local/tomcat

# Deploy as ROOT so the site is served at https://your-domain/ (the JSPs use contextPath everywhere)
COPY --from=build --chown=app:app /src/target/FruitBazar.war webapps/ROOT.war

USER 10001
EXPOSE 8080
CMD ["catalina.sh", "run"]
