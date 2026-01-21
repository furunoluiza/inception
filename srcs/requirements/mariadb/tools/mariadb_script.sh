#!/bin/bash
set -e

echo "🔍 Iniciando script de configuração do MariaDB..."

# --------------------------------------------------------------------
# 1. Leitura dos secrets (montados pelo Docker em /run/secrets)
# --------------------------------------------------------------------
DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
DB_USER_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# --------------------------------------------------------------------
# 2. Verificação de inicialização do banco da APLICAÇÃO
#    Se o diretório do banco existir, NÃO recriamos nada.
# --------------------------------------------------------------------
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "📂 Banco '${MYSQL_DATABASE}' já existe. Iniciando MariaDB..."
    exec mysqld --user=mysql --datadir=/var/lib/mysql
fi

echo "📦 Banco ainda não existe. Inicializando MariaDB pela primeira vez..."

# --------------------------------------------------------------------
# 3. Inicialização das tabelas do sistema (somente 1ª execução)
# --------------------------------------------------------------------
mysql_install_db --user=mysql --datadir=/var/lib/mysql

# --------------------------------------------------------------------
# 4. Subida TEMPORÁRIA do MariaDB (sem rede)
#    Usada apenas para executar comandos SQL de configuração
# --------------------------------------------------------------------
echo "🚀 Subindo MariaDB temporariamente para configuração..."
mysqld_safe --skip-networking --socket=/tmp/mysql.sock &

# Aguarda o MariaDB ficar pronto
until mysqladmin ping --socket=/tmp/mysql.sock >/dev/null 2>&1; do
    sleep 1
done

# --------------------------------------------------------------------
# 5. Configuração inicial:
#    - senha do root
#    - banco da aplicação
#    - usuário da aplicação
#    - permissões
# --------------------------------------------------------------------
echo "⚙️ Criando banco e usuários..."

mysql --socket=/tmp/mysql.sock <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOSQL

# --------------------------------------------------------------------
# 6. Encerramento da instância temporária
# --------------------------------------------------------------------
echo "🛑 Encerrando MariaDB temporário..."
mysqladmin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown

# --------------------------------------------------------------------
# 7. Subida DEFINITIVA do MariaDB em foreground (PID 1)
# --------------------------------------------------------------------
echo "✅ MariaDB configurado. Iniciando servidor principal..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
