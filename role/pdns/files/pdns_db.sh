#!/bin/bash

# chmod +x /tmp/pdns_db.sh && /bin/bash /tmp/pdns_db.sh

PDNS_DB_USER="powerdns"

read -s -p "Enter the password for the MariaDB $PDNS_DB_USER user : " PASSWORD

echo

SQL_COMMANDS=$(cat <<EOF
CREATE DATABASE $PDNS_DB_USER;
GRANT ALL ON $PDNS_DB_USER.* TO '$PDNS_DB_USER'@'%' IDENTIFIED BY '$PASSWORD';
FLUSH PRIVILEGES;
EOF
)

echo "${SQL_COMMANDS}" | /usr/bin/mariadb -u root

/usr/bin/mariadb -u $PDNS_DB_USER -p $PDNS_DB_USER < /usr/share/pdns-backend-mysql/schema/schema.mysql.sql
