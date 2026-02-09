FROM debian:12.11

# Instala PHP-FPM e dependências
RUN apt update && apt install -y \
    php-fpm \
    php-mysqli \
    curl \
    ca-certificates \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Copia configuração do PHP-FPM
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copia script de instalação do WordPress
COPY tools/wp-cli_script.sh /usr/local/bin/wp-cli_script.sh

# Permissão de execução
RUN chmod +x /usr/local/bin/wp-cli_script.sh

# Porta do PHP-FPM
EXPOSE 9000

# Executa script (que no final sobe o PHP-FPM)
CMD ["/usr/local/bin/wp-cli_script.sh"]