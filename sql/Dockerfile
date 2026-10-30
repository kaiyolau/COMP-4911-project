FROM mysql:8.4
COPY sql/init_scripts/ /docker-entrypoint-initdb.d/
CMD ["mysqld", "--performance-schema=OFF", "--innodb-buffer-pool-size=64M", "--skip-name-resolve"]
