#!/bin/sh
# Render supplies $PORT; keep the heap small for the free instance (512MB RAM).
export JAVA_OPTS="${JAVA_OPTS:--Xms64m -Xmx300m -XX:MaxMetaspaceSize=128m -Djava.net.preferIPv4Stack=true}"

export MYSQL_PWD="$MYSQL_PASSWORD"
DB_CLIENT="mariadb --ssl -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER"

# Create the schema once if it is missing (TiDB Cloud / any external MySQL).
$DB_CLIENT -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`" || echo "WARN: could not create database"
HAS_SCHEMA=$($DB_CLIENT -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$MYSQL_DATABASE' AND table_name='Employee'")
if [ "$HAS_SCHEMA" = "0" ]; then
  echo "Initialising schema from /sql/init_scripts"
  for f in /sql/init_scripts/*.sql; do
    echo "Running $f"
    $DB_CLIENT < "$f" || echo "WARN: $f failed"
  done
else
  echo "Schema present (Employee table: $HAS_SCHEMA), skipping init"
fi

# Point the WildFly datasource at the runtime env vars, over TLS.
URL="jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE?sslMode=REQUIRED"
cat > /tmp/ds.cli <<CLI
embed-server --server-config=standalone.xml --std-out=echo
/subsystem=datasources/data-source=MySQLDS:write-attribute(name=connection-url,value="$URL")
/subsystem=datasources/data-source=MySQLDS:write-attribute(name=user-name,value="\${env.MYSQL_USER}")
/subsystem=datasources/data-source=MySQLDS:write-attribute(name=password,value="\${env.MYSQL_PASSWORD}")
/subsystem=datasources/data-source=MySQLDS:read-resource
stop-embedded-server
CLI
"$JBOSS_HOME/bin/jboss-cli.sh" --file=/tmp/ds.cli 2>&1 | sed -E 's/("password" => ")[^"]*/\1***/' | grep -v -i "^\s*$" | head -60
rm -f /tmp/ds.cli

exec "$JBOSS_HOME/bin/standalone.sh" -b 0.0.0.0 -Djboss.http.port="${PORT:-8080}"
