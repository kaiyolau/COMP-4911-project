# Multi-stage build: Maven builds the WAR and provisions a trimmed WildFly, then a JRE-only image runs it.
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
COPY backend/pom.xml backend/pom.xml
COPY backend/src backend/src
RUN cd backend && mvn -B -q -Dmaven.test.skip=true package

FROM eclipse-temurin:21-jre
ENV JBOSS_HOME=/opt/server
COPY --from=build /build/backend/target/server $JBOSS_HOME
COPY backend/start.sh /start.sh
RUN chmod +x /start.sh $JBOSS_HOME/bin/*.sh
EXPOSE 8080
CMD ["/start.sh"]
