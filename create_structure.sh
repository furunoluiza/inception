#!/bin/bash
set -e

BASE_DIR="srcs"
REQ_DIR="$BASE_DIR/requirements"

# Create directory tree
mkdir -p \
  "$REQ_DIR/mariadb/conf" \
  "$REQ_DIR/mariadb/tools" \
  "$REQ_DIR/nginx/conf" \
  "$REQ_DIR/nginx/tools" \
  "$REQ_DIR/wordpress/conf" \
  "$REQ_DIR/wordpress/tools" \
  "secrets"

# Create root files
touch Makefile
touch "$BASE_DIR/docker-compose.yml"
touch "$BASE_DIR/.env"

# Create service files
touch "$REQ_DIR/mariadb/Dockerfile" "$REQ_DIR/mariadb/.dockerignore"
touch "$REQ_DIR/nginx/Dockerfile" "$REQ_DIR/nginx/.dockerignore"
touch "$REQ_DIR/wordpress/Dockerfile" "$REQ_DIR/wordpress/.dockerignore"

# Create secret files (empty placeholders)
touch \
  secrets/db_root_password.txt \
  secrets/wp_admin_password.txt \
  secrets/wp_db_password.txt \
  secrets/wp_user2_password.txt
