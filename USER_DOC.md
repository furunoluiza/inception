# User Documentation — Inception Project

This document explains, in clear and simple terms, how an end user or administrator can use the Inception Docker infrastructure.

---

## Services Provided by the Stack

The infrastructure provides the following services:

1. **WordPress Website**  
   A fully functional WordPress website accessible via HTTPS.

2. **WordPress Administration Panel**  
   An administration dashboard used to manage content, users, themes, and plugins.

3. **MariaDB Database**  
   A MySQL-compatible database that stores all WordPress data.

4. **NGINX Web Server**  
   A reverse proxy that handles HTTPS connections and forwards requests to WordPress.

All services are containerized and start automatically when the stack is launched.

---

## Starting the Project

1. **Navigate to the project directory**
```bash
cd inception
````

2. **Start all services**

```bash
make
```

This command will:

* Build Docker images if necessary
* Create the Docker network and volumes
* Start all containers
* Automatically configure WordPress

3. **Check container status**

```bash
docker compose -f srcs/docker-compose.yml ps
```

You should see three running containers:

* `nginx`
* `wordpress` (php-fpm)
* `mariadb`

---

## Stopping the Project

To stop all containers without deleting data:

```bash
cd inception
make fclean
```

This stops and removes containers while keeping volumes intact.

---

## Accessing the Website

1. **Configure the domain**
   Add the following line to `/etc/hosts`:

```bash
127.0.0.1 lfuruno.42.fr
```

2. **Open the website**

```text
https://lfuruno.42.fr
```

3. **SSL warning**
   A self-signed certificate is used.
   The browser will display a warning — accept it to continue.

If everything is correct, the WordPress homepage will load without showing the installation page.

---

## Accessing the Administration Panel

1. **Go to the admin page**

```text
https://lfuruno.42.fr/wp-admin
```

2. **Login credentials**

* Admin username: defined in `srcs/.env`
* Admin password: stored in `secrets/wp_admin_password.txt`

To view the password:

```bash
cat secrets/wp_admin_password.txt
```

⚠️ The admin username must **not** contain `admin` or `Administrator`.

---

## Managing Credentials

Sensitive credentials are stored as Docker secrets in:

```text
secrets/
```

Files include:

* `db_root_password.txt`
* `wp_db_password.txt`
* `wp_admin_password.txt`
* `wp_user2_password.txt`

### Viewing a credential

```bash
cat secrets/<filename>
```

### Changing credentials

⚠️ Changing secrets after the first setup may require a rebuild.

```bash
nano secrets/<filename>
make re
```

---

## Checking Service Status

### Check if containers are running

```bash
docker compose -f srcs/docker-compose.yml ps
```

All services should show `Up`.

### View logs

All services:

```bash
docker compose -f srcs/docker-compose.yml logs
```

Specific service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

---

## Verifying HTTPS and Connectivity

Test HTTPS:

```bash
curl -k https://lfuruno.42.fr
```

Check port 443:

```bash
sudo ss -tlnp | grep 443
```

---

## Verifying Data Persistence

1. Create a post or modify content in WordPress
2. Restart the project:

```bash
make clean
make
```

3. The changes should still be present

This confirms that volumes are working correctly.

---

## Data Location

Persistent data is stored on the host in:

* WordPress files:

```text
/home/lfuruno/data/wordpress/
```

* MariaDB data:

```text
/home/lfuruno/data/mariadb/
```

These directories remain intact even if containers are removed.

---

## Common Issues

**Website not accessible**

* Check containers: `docker compose ps`
* Verify `/etc/hosts`
* Check NGINX logs

**WordPress installation page appears**

* Database connection failed
* Check MariaDB logs

**SSL warning**

* Expected behavior with self-signed certificates

---

**End of USER Documentation**
