*This project has been created as part of the 42 curriculum by lfuruno.*

# Inception — Docker Orchestration Project

## Description

The **Inception** project is a system administration exercise whose goal is to design and deploy a complete infrastructure using **Docker** and **Docker Compose**.  
The objective is to set up a secure, modular, and persistent WordPress environment while respecting best practices in containerization and all constraints defined in the 42 subject.

The infrastructure is composed of three main services:

- **NGINX** — Web server and reverse proxy handling HTTPS connections using TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM** — Content management system and PHP execution layer
- **MariaDB** — Relational database management system storing WordPress data

Each service runs in its own container, built from a custom Dockerfile based on the **penultimate stable version of Debian**.  
All containers communicate through a **dedicated Docker network** and use **named volumes** to ensure data persistence.  
Sensitive information is handled via **Docker secrets**, while general configuration is managed through environment variables.

---

## Instructions

### Prerequisites

- Linux virtual machine
- Docker installed
- Docker Compose v2
- Root or sudo access for initial setup
- Basic knowledge of Docker concepts

---

### Docker Permissions

If Docker commands require `sudo`, your user is not part of the `docker` group.

Apply the group change in the current session:
```bash
newgrp docker
````

Or log out and log back in.

Verification:

```bash
docker ps
```

---

### Configuration and Execution

1. **Navigate to the project directory**

```bash
cd inception
```

2. **Configure environment variables**

* Edit `srcs/.env`
* Set your domain name (e.g. `lfuruno.42.fr`)

3. **Configure secrets**

* Edit files inside the `secrets/` directory
* Passwords must never be hardcoded in Dockerfiles or `docker-compose.yml`

4. **Update `/etc/hosts`**

```bash
sudo echo "127.0.0.1 lfuruno.42.fr" >> /etc/hosts
```

5. **Build and start the infrastructure**

```bash
make
```

6. **Access the website**

* Open `https://lfuruno.42.fr`
* Accept the self-signed certificate warning
* WordPress will be ready to use

---

### Makefile Commands

* `make` or `make inception` — Build and start all containers
* `make clean` — Stop and remove containers
* `make fclean` — Remove containers, images, volumes, and networks
* `make re` — Rebuild everything from scratch

---

## Resources

### Documentation

* Docker — [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose — [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* NGINX — [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
* WordPress — [https://wordpress.org/support/](https://wordpress.org/support/)
* MariaDB — [https://mariadb.com/kb/en/documentation/](https://mariadb.com/kb/en/documentation/)
* PHP-FPM — [https://www.php.net/manual/en/install.fpm.php](https://www.php.net/manual/en/install.fpm.php)

---

### AI Usage

AI tools were used for:

* Reviewing Dockerfiles and `docker-compose.yml`
* Validating containerization and security best practices
* Assisting in debugging networking and volume issues
* Improving documentation structure and clarity

All AI-assisted content was reviewed, fully understood, and tested before being integrated into the project.

---

## Project Description

### Docker Usage

Docker is used to isolate each service into its own container, ensuring modularity, reproducibility, and easier maintenance.
Docker Compose orchestrates the containers, manages dependencies, networks, and volumes.

**Main Docker features used:**

* Docker Compose
* Custom Docker network
* Named volumes for persistence
* Docker secrets for sensitive data
* Foreground process execution (no background hacks)

---

### Project Structure

```
inception/
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   ├── wp_db_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
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

## Design Choices and Comparisons

### Virtual Machines vs Docker

**Virtual Machines**

* Full operating system per instance
* High resource consumption
* Slow startup times

**Docker**

* Shares host kernel
* Lightweight and fast
* Ideal for multi-service applications

**Why Docker**
Docker provides sufficient isolation with significantly lower overhead, making it the best choice for this project.

---

### Secrets vs Environment Variables

**Environment Variables**

* Used for non-sensitive configuration
* Easy to modify
* Visible inside containers

**Docker Secrets**

* Mounted as read-only files
* Not exposed as environment variables
* Designed for passwords and credentials

**Usage in this project**
Secrets are used for sensitive data, while environment variables handle general configuration.

---

### Docker Network vs Host Network

**Host Network**

* No isolation
* Services directly exposed
* Less secure

**Docker Network**

* Isolated virtual network
* Containers communicate by service name
* Better security and control

**Usage in this project**
Only NGINX is exposed to the host.
WordPress and MariaDB communicate exclusively through the `inception` Docker network.

---

### Docker Volumes vs Bind Mounts

**Bind Mounts**

* Direct link to host filesystem
* Less portable

**Docker Volumes**

* Managed by Docker
* More portable and safer

**Project choice**
Named volumes backed by `/home/lfuruno/data/`, ensuring persistence and compliance with subject requirements.

---

**End of README**