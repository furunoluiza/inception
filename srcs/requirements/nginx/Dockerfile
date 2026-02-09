# Imagem base exigida pelo subject (Debian)
FROM debian:12.11

# Atualiza os repositórios, instala o nginx e o openssl
# Remove o cache do apt para reduzir o tamanho da imagem
RUN apt update && \
    apt install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Cria diretórios necessários:
# - /etc/nginx/certs → certificados SSL
# - /run/nginx       → arquivo PID do nginx
RUN mkdir -p /etc/nginx/certs /run/nginx

# Remove a configuração default do nginx para evitar conflitos
RUN rm -f /etc/nginx/sites-enabled/default

# Argumento usado em build time para definir o nome do servidor (CN do certificado)
ARG SERVER_NAME=localhost

# Gera um certificado SSL autoassinado:
# - x509        → certificado autoassinado
# - nodes       → sem senha (necessário para containers)
# - days 365    → validade de 1 ano
# - rsa:2048    → chave RSA de 2048 bits
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/certs/privkey.pem \
    -out /etc/nginx/certs/fullchain.pem \
    -subj "/CN=${SERVER_NAME}"

# Copia a configuração customizada do nginx
# Normalmente contém configuração SSL e proxy para o PHP-FPM
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Expõe a porta HTTPS
EXPOSE 443

# Inicia o nginx em foreground (obrigatório em containers Docker)
CMD ["nginx", "-g", "daemon off;"]
