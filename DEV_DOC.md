# Developer Documentation — Inception Project

This document provides technical instructions for developers on how to set up, build, run, and maintain the Inception Docker infrastructure from scratch.

It is intended for developers who need to understand the project architecture, configuration choices, container orchestration, and data persistence mechanisms.

---

## Prerequisites

Before starting, ensure the following requirements are met:

- **Linux Virtual Machine** (mandatory per project specifications)
- **Docker** (version 20.10 or later)
- **Docker Compose v2**
- **Git**
- **Root or sudo privileges**
- Basic knowledge of:
  - Docker and containerization
  - Docker Compose
  - Linux system administration
  - Shell scripting

---

## Installing Docker and Docker Compose

If Docker is not installed, follow these steps (Debian-based systems):

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
````

Add your user to the Docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Verify installation:

```bash
docker --version
docker compose version
```

---

## Project Structure

The project follows this structure:

```
inception/
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   ├── wp_db_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user2_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

---

## Environment Configuration

### `.env` File

Create `srcs/.env`:

```env
SERVER_NAME=lfuruno.42.fr

DB_HOST=mariadb
DB_NAME=wordpress
DB_USER=wpuser

WP_URL=https://lfuruno.42.fr
WP_TITLE=Inception

WP_ADMIN_USER=super_lfuruno
WP_ADMIN_EMAIL=lfuruno@gmail.com

WP_USER2=lfuruno_user
WP_USER2_EMAIL=lfuruno_user@gmail.com
WP_USER2_ROLE=author
```

> ⚠️ The admin username must NOT contain `admin` or `Administrator`.

---

## Docker Secrets

Create secrets in the `secrets/` directory:

```bash
mkdir -p secrets

echo "root_password" > secrets/db_root_password.txt
echo "wp_db_password" > secrets/wp_db_password.txt
echo "wp_admin_password" > secrets/wp_admin_password.txt
echo "wp_user2_password" > secrets/wp_user2_password.txt

chmod 600 secrets/*.txt
```

Secrets are mounted read-only inside containers and are never exposed as environment variables.

---

## Domain Configuration

Add the domain to `/etc/hosts`:

```bash
sudo echo "127.0.0.1 lfuruno.42.fr" >> /etc/hosts
```

---

## Data Directories (Persistence)

Create data directories on the host:

```bash
mkdir -p /home/lfuruno/data/wordpress
mkdir -p /home/lfuruno/data/mariadb
sudo chown -R $USER:$USER /home/lfuruno/data
```

---

## Build and Launch the Project

### Using the Makefile

```bash
cd inception
make            # Build and start containers
make clean      # Stop containers
make fclean     # Remove containers, images, volumes, networks
make re         # Full rebuild
```

### Using Docker Compose Directly

```bash
cd srcs
docker compose up -d --build
docker compose down
docker compose logs -f
```

---

## Container Startup Order

1. **MariaDB**

   * Initializes database if not present
   * Creates users and database
   * Starts `mysqld`

2. **WordPress**

   * Waits for MariaDB
   * Downloads WordPress
   * Generates `wp-config.php`
   * Installs WordPress via WP-CLI
   * Starts `php-fpm`

3. **NGINX**

   * Uses TLS (v1.2 / v1.3)
   * Acts as reverse proxy
   * Exposes only port 443

---

## Managing Containers

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml exec wp-php bash
docker compose -f srcs/docker-compose.yml restart nginx
```

---

## Volumes and Persistence

### Volumes Used

* `wordpress_data` → `/home/lfuruno/data/wordpress`
* `mariadb_data` → `/home/lfuruno/data/mariadb`

### Verify Persistence

1. Create a WordPress post
2. Stop containers: `make clean`
3. Restart: `make`
4. Data remains intact

---

## Network Architecture

All containers communicate through a custom Docker network:

```
Client
  ↓
NGINX (443)
  ↓
WordPress (php-fpm)
  ↓
MariaDB
```

* No `network: host`
* No `links`
* Only NGINX is exposed to the host

---

## Debugging

```bash
docker compose logs nginx
docker compose logs wp-php
docker compose logs mariadb
```

Check secrets:

```bash
docker compose exec wp-php ls /run/secrets
```

---

## Backup and Restore

### Backup WordPress

```bash
tar -czf wordpress_backup.tar.gz /home/lfuruno/data/wordpress
```

### Backup Database

```bash
docker compose exec mariadb \
mysqldump -u root -p$(cat ../secrets/db_root_password.txt) wordpress > backup.sql
```

---

## Reset Everything

```bash
make fclean
rm -rf /home/lfuruno/data/*
make
```

---

## Summary

This document explains how developers can:

* Set up the environment from scratch
* Configure secrets and environment variables
* Build and run the project using Docker and Makefile
* Manage containers, volumes, and networks
* Understand how data persistence works

---

**For end-user instructions, see `USER_DOC.md`.**