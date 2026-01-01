# Conduit Deployment

This repository contains the **deployment configuration** for the Conduit full-stack application, a Medium.com clone. The setup uses Docker and Docker Compose to orchestrate a complete production environment.

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

---

## Description

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
git clone git clone -b feature/conduit-container git@github.com:Ozinho78/conduit-deployment.git
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
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,backend,<YOUR_VM_IP_HERE>
CORS_ALLOWED_ORIGINS=http://localhost:8282,http://<YOUR_VM_IP_HERE>:8282
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
- **Frontend**: `http://<YOUR_VM_IP:8282>`
- **Backend API**: `http://<YOUR_VM_IP>:8000/api`
- **Backend Admin**: `http://<YOUR_VM_IP>:8000/admin`

---

## Usage

### Initial Setup

**Directory structure after setup:**

```bash
conduit-deployment/
├── .dockerignore               # Excludes Python cache, venv, .git, node_modules, dist from Docker context
├── docker-compose.yaml         # Orchestration: frontend, backend, postgres services
├── .env.example                # Template for .env, contains environment variables
├── .env                        # Runtime environment variables (NOT in Git!), created by YOU
├── .gitignore                  # Excludes .env, logs, IDE configs, OS files
├── README.md                   # This document, project documentation with ToC, quickstart, usage
├── conduit-frontend/           # contains frontend code, coded with Angular
│   └── frontend.Dockerfile     # Multi-stage build: Angular build + npm serve
├── conduit-backend/            # Contains backend code, coded with Django
│   └── backend.Dockerfile      # Multi-stage build: Django app + Gunicorn WSGI
│   └── entrypoint.sh           # Defines and controls default commands when container starts
│   └── conduit/
│       └── settings.py         # Must be modified for production (ALLOWED_HOSTS, DB config)
```

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
   DJANGO_SECRET_KEY=<your_generated_key_here>
   ```

3. **Allowed Hosts** (REQUIRED for production):
   Replace `YOUR_VM_IP_HERE` with your actual VM IP address:
   ```bash
   DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,backend,<YOUR_VM_IP_HERE>
   CORS_ALLOWED_ORIGINS=http://localhost:8282,http://<YOUR_VM_IP_HERE>:8282
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
| Frontend | `http://<YOUR_VM_IP>:8282` | Angular SPA |
| Backend API | `http://<YOUR_VM_IP>:8000/api` | REST API endpoints |
| Admin Panel | `http://<YOUR_VM_IP>:8000/admin` | Django admin interface |

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
> ⚠️ **WARNING**
> This deletes all database data!
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

**Project Information**
- **Last Updated**: January 2026
- **Course**: DevSecOps
- **Project**: Conduit Containerization
