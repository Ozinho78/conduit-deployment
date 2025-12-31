# Conduit Deployment

Production-ready containerized deployment for the Conduit application (Medium.com clone).

---

## Table of Contents

1. [Description](#description)
2. [Prerequisites](#prerequisites)
3. [Quickstart](#quickstart)
4. [Usage](#usage)
   - [Environment Configuration](#environment-configuration)
   - [Building and Running](#building-and-running)
   - [Accessing the Application](#accessing-the-application)
   - [Managing Services](#managing-services)
   - [Working with Logs](#working-with-logs)
5. [Configuration](#configuration)
   - [Environment Variables](#environment-variables)
   - [Port Mappings](#port-mappings)
   - [Data Persistence](#data-persistence)
6. [Troubleshooting](#troubleshooting)

---

## Description

This repository contains the **deployment configuration** for the Conduit full-stack application, a Medium.com clone. The setup uses Docker and Docker Compose to orchestrate a complete production environment.

### Components

- **Frontend**: Angular Single Page Application (SPA) served with Node.js `serve` package
- **Backend**: Django REST API running with Gunicorn WSGI server
- **Database**: PostgreSQL for data persistence

### Purpose

This is a containerized deployment using multi-stage Docker builds to minimize image sizes while maintaining production-ready configuration. All services are orchestrated via Docker Compose with proper volume management for data persistence and automatic restart policies.

---

## Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Git**: For repository management

Verify installations:
```bash
docker --version
docker compose version
git --version
```

---

## Quickstart

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd conduit-deployment
```

### 2. Create environment file
```bash
cp .env.example .env
```

### 3. Configure environment variables
Edit `.env` and set **required** values:
```bash
# REQUIRED: Set secure password
POSTGRES_PASSWORD=your_secure_password_here

# REQUIRED: Generate Django secret key
DJANGO_SECRET_KEY=your_generated_secret_key_here

# REQUIRED: Add your VM IP address
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,backend,YOUR_VM_IP_HERE
CORS_ALLOWED_ORIGINS=http://localhost:8282,http://YOUR_VM_IP_HERE:8282
```

**Generate Django Secret Key:**
```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### 4. Build and start services
```bash
docker compose up -d --build
```

### 5. Access application
- **Frontend**: `http://YOUR_VM_IP:8282`
- **Backend API**: `http://YOUR_VM_IP:8000/api`
- **Backend Admin**: `http://YOUR_VM_IP:8000/admin`

---

## Usage

### Environment Configuration

The `.env` file contains all configuration for the deployment. This file is **not** stored in Git for security reasons.

**Create from template:**
```bash
cp .env.example .env
nano .env  # or use your preferred editor
```

**Critical settings to modify:**

1. **Database Password** (REQUIRED):
   ```bash
   POSTGRES_PASSWORD=use_a_strong_random_password
   ```

2. **Django Secret Key** (REQUIRED):
   Generate using Python:
   ```bash
   python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
   ```
   Then set in `.env`:
   ```bash
   DJANGO_SECRET_KEY=your_generated_key_here
   ```

3. **Allowed Hosts** (REQUIRED for production):
   Replace `YOUR_VM_IP_HERE` with your actual VM IP address:
   ```bash
   DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,backend,192.168.1.100
   CORS_ALLOWED_ORIGINS=http://localhost:8282,http://192.168.1.100:8282
   ```

**Optional settings:**

- `DEBUG`: Set to `True` only for development (default: `False`)
- `POSTGRES_DB`: Database name (default: `conduit`)
- `POSTGRES_USER`: Database user (default: `conduit`)
- `FRONTEND_PORT`: External port for frontend (default: `8282`)
- `BACKEND_PORT`: External port for backend (default: `8000`)

### Building and Running

**First-time build:**
```bash
docker compose up -d --build
```

**Start existing containers:**
```bash
docker compose up -d
```

**Rebuild after code changes:**
```bash
docker compose up -d --build
```

**Check service status:**
```bash
docker compose ps
```

Expected output:
```
NAME                IMAGE                      STATUS
conduit-backend     conduit-deployment-backend Up
conduit-database    postgres:13-alpine         Up
conduit-frontend    conduit-deployment-frontend Up
```

### Accessing the Application

Once services are running, access the application at:

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | `http://YOUR_VM_IP:8282` | Angular SPA |
| Backend API | `http://YOUR_VM_IP:8000/api` | REST API endpoints |
| Admin Panel | `http://YOUR_VM_IP:8000/admin` | Django admin interface |

**Create superuser for admin access:**
```bash
docker compose exec backend python manage.py createsuperuser
```

### Managing Services

**Stop services (keeps data):**
```bash
docker compose stop
```

**Start stopped services:**
```bash
docker compose start
```

**Restart all services:**
```bash
docker compose restart
```

**Restart specific service:**
```bash
docker compose restart backend
docker compose restart frontend
docker compose restart database
```

**Stop and remove containers (keeps volumes):**
```bash
docker compose down
```

**Stop and remove everything including data:**
> ⚠️ **WARNING**: This deletes all database data!
```bash
docker compose down -v
```

### Working with Logs

**View all logs:**
```bash
docker compose logs
```

**Follow logs in real-time:**
```bash
docker compose logs -f
```

**View logs for specific service:**
```bash
docker compose logs backend
docker compose logs frontend
docker compose logs database
```

**Follow specific service logs:**
```bash
docker compose logs -f backend
```

**Save logs to file:**
```bash
# Save backend logs
docker logs conduit-backend > backend-logs.txt

# Save frontend logs
docker logs conduit-frontend > frontend-logs.txt

# Save database logs
docker logs conduit-database > database-logs.txt

# Save all logs with timestamps
docker compose logs --timestamps > all-logs.txt
```

**View last N lines:**
```bash
docker compose logs --tail=100 backend
```

---

## Configuration

### Environment Variables

All environment variables are defined in `.env` file. This file is excluded from Git via `.gitignore`.

**Database Configuration:**
```bash
POSTGRES_DB=conduit              # Database name
POSTGRES_USER=conduit            # Database user
POSTGRES_PASSWORD=<required>     # Database password (MUST be set!)
```

**Django Configuration:**
```bash
DJANGO_SECRET_KEY=<required>     # Secret key (MUST be set!)
DEBUG=False                      # Debug mode (False for production)
DJANGO_ALLOWED_HOSTS=<hosts>     # Comma-separated allowed hosts
```

**CORS Configuration:**
```bash
CORS_ALLOWED_ORIGINS=<urls>      # Comma-separated allowed origins
```

**Port Configuration:**
```bash
FRONTEND_PORT=8282               # External frontend port
BACKEND_PORT=8000                # External backend port
```

### Port Mappings

The following ports are exposed to the host system:

| Service | Container Port | Host Port | Configurable via |
|---------|---------------|-----------|------------------|
| Frontend | 80 | 8282 | `FRONTEND_PORT` |
| Backend | 8000 | 8000 | `BACKEND_PORT` |
| Database | 5432 | - | Internal only |

**To change ports:**
Edit `.env` file and modify `FRONTEND_PORT` or `BACKEND_PORT`, then restart:
```bash
docker compose down
docker compose up -d
```

### Data Persistence

Docker volumes are used to persist data across container restarts:

| Volume | Purpose | Data Location |
|--------|---------|---------------|
| `postgres_data` | Database storage | PostgreSQL data directory |
| `static_volume` | Static files | Django collected static files |
| `media_volume` | Media uploads | User-uploaded media files |

**Volume locations:**
```bash
# List all volumes
docker volume ls

# Inspect specific volume
docker volume inspect conduit-deployment_postgres_data
```

**Backup database:**
```bash
docker compose exec database pg_dump -U conduit conduit > backup.sql
```

**Restore database:**
```bash
docker compose exec -T database psql -U conduit conduit < backup.sql
```

---

## Troubleshooting

### Service won't start

**Check logs:**
```bash
docker compose logs backend
docker compose logs frontend
docker compose logs database
```

**Common issues:**

1. **Port already in use:**
   ```
   Error: bind: address already in use
   ```
   Solution: Change port in `.env` or stop conflicting service

2. **Missing .env file:**
   ```
   Error: required variable not set
   ```
   Solution: Copy `.env.example` to `.env` and configure

3. **Database connection fails:**
   ```
   Error: could not connect to server
   ```
   Solution: Wait for database to be ready, then restart backend:
   ```bash
   docker compose restart backend
   ```

### Frontend shows 404 errors

**Check backend is running:**
```bash
docker compose ps backend
```

**Verify CORS configuration:**
Ensure `CORS_ALLOWED_ORIGINS` in `.env` includes your frontend URL

**Check backend logs:**
```bash
docker compose logs backend
```

### Database data lost

Volumes must be created before first run. If you used `docker compose down -v`, all data is deleted.

**Prevent data loss:**
- Use `docker compose down` without `-v` flag
- Regular backups recommended

### Cannot access from VM IP

**Check ALLOWED_HOSTS:**
```bash
# In .env file
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,backend,YOUR_VM_IP
```

**Check firewall:**
```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 8282
sudo ufw allow 8000
```

### Rebuild everything from scratch

```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Remove images
docker compose down --rmi all

# Rebuild and start
docker compose up -d --build
```

---

**Project Information**
- **Course**: DevSecOps
- **Institution**: Developer Akademie
- **Project**: Conduit Containerization
- **Last Updated**: December 2025
