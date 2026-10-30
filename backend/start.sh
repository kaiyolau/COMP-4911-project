#!/bin/sh
# Render supplies $PORT; keep the heap small for the free instance (512MB RAM).
export JAVA_OPTS="${JAVA_OPTS:--Xms64m -Xmx300m -XX:MaxMetaspaceSize=128m -Djava.net.preferIPv4Stack=true}"
exec "$JBOSS_HOME/bin/standalone.sh" -b 0.0.0.0 -Djboss.http.port="${PORT:-8080}"
