#!/bin/bash

echo "setuping lighttpd wordpress mariadb stack"

wpuserpw=$(echo "1254P4ssw@rd")
apt install lighttpd mariadb-server mariadb-client php php-mysql php-cgi -y
wget https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
tar xf /tmp/wp.tar.gz -C /tmp
cp -r /tmp/wordpress/* /var/www/html

echo "creating database for wordpress"

mysql -e "
    CREATE DATABASE wpdb;
    CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '$wpuserpw';
    GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost';
    FLUSH PRIVILEGES;
"
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i "s/database_name_here/wpdb/g" /var/www/html/wp-config.php
sed -i "s/username_here/wpuser/g" /var/www/html/wp-config.php
sed -i "s/password_here/$wpuserpw/g" /var/www/html/wp-config.php

lighty-enable-mod fastcgi
lighty-enable-mod fastcgi-php
service lighttpd force-reload
systemctl restart lighttpd.service

echo "setuping ftp server"

useradd wpuser
adduser wpuser www-data
chown -R wpuser:www-data /var/www/html
ln -s /var/www/html /home/wpuser
usermod -d /home/wpuser wpuser

apt install vsftpd -y
sed -i "s/#write_enable.*/write_enable=YES/" /etc/vsftpd.conf
sed -i "s/#chroot_local_user.*/chroot_local_user=YES/" /etc/vsftpd.conf
echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf
systemctl restart vsftpd.service
ufw allow 80
ufw enable
clear 
ufw status 
echo "\
wordpress has been set
navigate to http://$(hostname -I) to finish wordpress install
ftp user for wordpress is wpuser -> $wpuserpw
Auf Wiedersehen!
"