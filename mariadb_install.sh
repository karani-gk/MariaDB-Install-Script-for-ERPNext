MYSQL_PASS=''

echo 'Enter your preferred MySQL root password'
read MYSQL_PASS

##################################################################
# 4 - UPDATE THE SYSTEM
##################################################################
echo -e "\033[0;33m \n>\n> Updating system packages \n>\n\033[0m"
apt -y update
apt -y -o DPkg::options::="--force-confdef" upgrade

##################################################################
# 11 - INSTALL NGINX AND MARIADB
##################################################################
echo -e "\033[0;33m \n>\n> Installing nginx and mariadb \n>\n\033[0m"
apt -y install nginx
apt -y install mariadb-server mariadb-client libmysqlclient-dev


##################################################################
# 12 - CHANGE DATABASE CONFIGURATIONS TO SUIT ERPNEXT AND FRAPPE
##################################################################
sed -i 's/\[mysqld\]/[mysqld]\ncharacter-set-client-handshake = FALSE/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/\[mysql\]/[mysql]\ndefault-character-set = utf8mb4/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/utf8mb4_general_ci/utf8mb4_unicode_ci/' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mysqld


##################################################################
# 13 - SECURING OUR DATABASE
##################################################################
echo -e "\033[0;33m \n>\n> Securing database \n>\n\033[0m"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root';"
mysql -e "UPDATE mysql.user SET Password=PASSWORD('${MYSQL_PASS}') WHERE User='root';"
mysql -e "FLUSH PRIVILEGES;"
echo -e "Database password = ${MYSQL_PASS} \n"