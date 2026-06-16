# nginx-php-mysql-setup-in-linux

This bash file installs Nginx, PHP, and MySQL, and configures Nginx to work with PHP easily.
It also include phpmyadmin.

## Requirements
- `apt`

## Installation
```bash
wget https://raw.githubusercontent.com/yvesnda/nginx-php-mysql-setup-in-linux/refs/heads/main/setup_nginx_php_mysql.sh
bash setup_nginx_php_mysql.sh
```
or in 1 command

```bash
wget https://raw.githubusercontent.com/yvesnda/nginx-php-mysql-setup-in-linux/refs/heads/main/setup_nginx_php_mysql.sh & bash setup_nginx_php_mysql.sh
```

## Test
- Tested on Ubuntu 24 and worked well

## Future
- Allow adding mutliple domain and mutliple user
- Allow php extensions selection per domain
- Setup KodExplorer as file manager
- Option to add vscode
