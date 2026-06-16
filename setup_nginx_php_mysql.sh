#!/bin/bash

set -e

PHP_VERSION="8.3"
MYSQL_ROOT_PASSWORD="ChangeMeStrongPassword"

echo "Updating system..."
apt update -y
apt upgrade -y

echo "Installing NGINX..."
apt install -y nginx

echo "Installing MySQL Server..."
apt install -y mysql-server

echo "Securing MySQL..."
mysql --user=root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Installing PHP and extensions..."
apt install -y \
          php${PHP_VERSION}-fpm \
            php${PHP_VERSION}-cli \
              php${PHP_VERSION}-mysql \
                php${PHP_VERSION}-curl \
                  php${PHP_VERSION}-gd \
                    php${PHP_VERSION}-mbstring \
                      php${PHP_VERSION}-xml \
                        php${PHP_VERSION}-zip

echo "Enabling and starting services..."
systemctl enable nginx mysql php${PHP_VERSION}-fpm
systemctl start nginx mysql php${PHP_VERSION}-fpm

echo "Configuring NGINX for PHP..."
NGINX_CONF="/etc/nginx/sites-available/default"

cat > $NGINX_CONF <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "Testing NGINX configuration..."
nginx -t

echo "Reloading NGINX..."
systemctl reload nginx

echo "Creating PHP + MySQL test file..."
cat > /var/www/html/index.php <<EOF
<?php
\$conn = new mysqli("localhost", "root", "${MYSQL_ROOT_PASSWORD}");
if (\$conn->connect_error) {
    die("MySQL Connection Failed: " . \$conn->connect_error);
}
echo "✅ PHP + MySQL is working!";
?>
EOF

echo "Setting permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "====================================="
echo "✅ LEMP stack installed successfully!"
echo "MySQL root password: ${MYSQL_ROOT_PASSWORD}"
echo "Visit http://YOUR_SERVER_IP/"
echo "====================================="
