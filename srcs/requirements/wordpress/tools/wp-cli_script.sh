#!/bin/bash
set -e

# 1. Ir para o diretório do WordPress #
cd /var/www/html


# 2. Esperar o banco de dados subir   #
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping \
    -h"${DB_HOST}" \
    -u"${DB_USER}" \
    -p"$(cat ${DB_PASSWORD_FILE})" \
    --silent; do
    sleep 2
done
echo "MariaDB is ready!"


# 3. Baixar wp-cli (se não existir)  #
if [ ! -f wp-cli.phar ]; then
    echo "Downloading wp-cli..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
fi


# 4. Instalar e configurar WordPress #
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress core..."
    ./wp-cli.phar core download --allow-root

    echo "Creating wp-config.php..."
    ./wp-cli.phar config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="$(cat ${DB_PASSWORD_FILE})" \
        --dbhost="${DB_HOST}" \
        --allow-root

    echo "Installing WordPress..."
    ./wp-cli.phar core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="$(cat ${WP_ADMIN_PASSWORD_FILE})" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
fi


# 5. Criar segundo usuário (opcional)#
if ! ./wp-cli.phar user get "${WP_USER2}" --allow-root >/dev/null 2>&1; then
    echo "Creating secondary user..."
    ./wp-cli.phar user create \
        "${WP_USER2}" "${WP_USER2_EMAIL}" \
        --role="${WP_USER2_ROLE}" \
        --user_pass="$(cat ${WP_USER2_PASSWORD_FILE})" \
        --allow-root
fi


# 6. Iniciar PHP-FPM (processo final)#
echo "Starting PHP-FPM..."
php-fpm8.2 -F
