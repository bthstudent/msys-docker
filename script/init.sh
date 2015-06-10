#!/bin/bash
if [ ! -f /usr/share/nginx/msys-master/local-config.php ]; then
    # Mysql has to be started
    /usr/bin/mysqld_safe &
    sleep 10s

    # Generate config stuff
    MEMBER_DB="member"
    MYSQL_PASSWORD=$(pwgen -c -n -1 12)
    MEMBER_PASSWORD=$(pwgen -c -n -1 12)
    MEMBER_USER="member"

    # Echo it out
    echo mysql root password: "$MYSQL_PASSWORD"
    echo "$MEMBER_USER" password: "$MEMBER_PASSWORD"
    echo "$MYSQL_PASSWORD" > /mysql-root-pw.txt
    echo "$MEMBER_PASSWORD" > /member-db-pw.txt

    sed -e "s/sqlhost.example.com/localhost/
  s/database_name/$MEMBER_DB/
  s/db_password/$MEMBER_PASSWORD/
  s/db_user/$MEMBER_USER/
  s/3f46781d4ad88ad67885122d25a8e47c/$(pwgen -c -n -1 16)/" /usr/share/nginx/msys-master/example-config.php > /usr/share/nginx/msys-master/local-config.php

    chown -R www-data:www-data /usr/share/nginx

    mysqladmin -u root password "$MYSQL_PASSWORD"
    mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql -uroot -p"$MYSQL_PASSWORD" -e "CREATE DATABASE $MEMBER_DB; GRANT ALL PRIVILEGES ON $MEMBER_DB.* TO '$MEMBER_USER'@'localhost' IDENTIFIED BY '$MEMBER_PASSWORD'; FLUSH PRIVILEGES;"
    mysql -uroot -p"$MYSQL_PASSWORD" "$MEMBER_DB" < /usr/share/nginx/msys-master/db/db.sql
    killall mysqld
fi

# Start all services
/usr/local/bin/supervisord -n
