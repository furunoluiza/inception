FROM debian:12.11

RUN apt update && apt install -y mariadb-server && \
    mkdir -p /run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld /var/log/mysql

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY tools/mariadb_script.sh /

RUN chmod +x /mariadb_script.sh

EXPOSE 3306

CMD ["/mariadb_script.sh"]
