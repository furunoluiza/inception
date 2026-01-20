#!/bin/bash

# Faz o script abortar imediatamente se qualquer comando retornar erro.
# Isso evita deixar o banco em um estado inconsistente.
set -e

echo "🔍 Verificando diretório de dados do MariaDB..."

# Leitura dos secrets do Docker.
# Secrets não são passados como variáveis de ambiente,
# mas sim como arquivos montados no container.
DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
DB_USER_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Verifica se o banco já foi inicializado anteriormente.
# A existência do diretório /var/lib/mysql/mysql indica
# que o volume persistente já contém os dados do sistema.
# Nesse caso, não recriamos o banco (idempotência).
if [ -d "/var/lib/mysql/mysql" ]; then
    echo "📂 Banco já existe. Iniciando MariaDB normalmente..."
    # Inicia o MariaDB em foreground para manter o container ativo.
    exec mysqld_safe
fi

echo "📦 Inicializando diretório de dados do MariaDB..."

# Inicializa as tabelas do sistema do MariaDB.
# Em imagens Debian puras, isso precisa ser feito manualmente.
mysql_install_db --user=mysql --datadir=/var/lib/mysql

echo "🚀 Iniciando MariaDB temporariamente..."

# Inicia o MariaDB de forma temporária, sem habilitar rede.
# Isso permite apenas conexões locais via socket Unix,
# evitando conexões externas durante a configuração inicial.
mysqld_safe --skip-networking --socket=/tmp/mysql.sock &
pid="$!"

# Aguarda o MariaDB ficar pronto para aceitar conexões.
# Isso evita condições de corrida ao executar comandos SQL.
until mysqladmin ping --socket=/tmp/mysql.sock >/dev/null 2>&1; do
    sleep 1
done

echo "⚙️ Configurando banco de dados e usuários..."

# Executa os comandos SQL necessários para a configuração inicial:
# - Define a senha do usuário root
# - Cria o banco de dados da aplicação, se não existir
# - Cria o usuário da aplicação, se não existir
# - Concede privilégios ao usuário sobre o banco
# - Atualiza as permissões
mysql --socket=/tmp/mysql.sock <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOSQL

echo "🛑 Encerrando MariaDB temporário..."

# Finaliza corretamente a instância temporária do MariaDB
# após a configuração inicial.
mysqladmin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown

echo "✅ MariaDB configurado. Iniciando servidor principal..."

# Inicia o MariaDB definitivamente em foreground.
# O uso de 'exec' garante que o processo assuma o PID 1,
# permitindo o tratamento correto de sinais pelo Docker.
exec mysqld_safe
