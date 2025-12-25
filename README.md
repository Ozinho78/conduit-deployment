# Conduit Deployment

Production-ready containerized deployment for the Conduit application (Medium.com clone).

---

## Table of Contents

1. [Description](#description)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Quickstart](#quickstart)
5. [Usage](#usage)
   - [Initial Setup](#initial-setup)
   - [Backend PostgreSQL Configuration](#backend-postgresql-configuration)
   - [Environment Configuration](#environment-configuration)
   - [Building and Running](#building-and-running)
   - [Testing](#testing)
   - [Logs](#logs)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)

---

## Description

This repository contains the **deployment configuration** for the Conduit full-stack application.

**Components:**
- **Backend**: Django REST API with Gunicorn WSGI server
- **Frontend**: Angular Single Page Application (SPA) served via Nginx
- **Database**: PostgreSQL for data persistence
- **Proxy**: Nginx reverse proxy for static files and API routing

**Purpose:** This is a **deployment-only repository**. The application source code (frontend and backend) are maintained in separate repositories and cloned into this structure.

---

## Prerequisites

- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: For cloning repositories

Verify:
```bash
docker --version
docker compose version
```

---

## Quickstart

### 1. Clone this deployment repo
```bash
git clone -b feature/container-deployment git@github.com:Ozinho78/conduit-deployment.git
cd conduit-deployment
```

### 2. Clone application repositories
```bash
git clone git@github.com:Ozinho78/conduit-backend.git
git clone git@github.com:Ozinho78/conduit-frontend.git
```

### 3. Copy files
**The script copies all necessary files into frontend and backend directory**
```bash
# Windows
.\deploy.ps1

# Linux
chmod +x ./deploy.sh
./deploy.sh
```

Configure backend for PostgreSQL

### 5. Create .env file
**Set POSTGRES_PASSWORD, DJANGO_SECRET_KEY, YOUR_VM_IP**
```bash
cp .env.example .env
nano .env
```

### 6. Start services
```bash
docker compose up -d --build
```

### 7. Access application
Frontend: http://<YOUR_VM_IP>:8282
Backend:  http://<YOUR_VM_IP>:8000/admin or http://<YOUR_VM_IP>:8000/api

---

## Usage

### Initial Setup

**Directory structure after setup:**

```bash
conduit-deployment/
├── backend.Dockerfile
├── frontend.Dockerfile
├── nginx-backend.conf          # Backend Nginx config
├── nginx-frontend.conf         # Frontend Nginx config
├── docker-compose.yaml
├── .env.example                # template for .env
├── .env                        # Created by you (NOT in Git!)
├── .gitignore
├── README.md                   # this document
├── backend.dockerignore
├── frontend.dockerignore
├── conduit-backend/            # Cloned from separate repo
│   └── conduit/
│       └── settings.py         # Must be modified!
└── conduit-frontend/           # Cloned from separate repo
```

## Backend PostgreSQL Configuration

**CRITICAL:** The backend must be modified to use PostgreSQL.

#### Step 1: Add PostgreSQL dependencies

Edit `conduit-backend/requirements.txt` and add:

```txt
psycopg2-binary==2.7.7
django-cors-headers==2.1.0
gunicorn==19.9.0
```

#### Step 2: Update Django settings

Edit `conduit-backend/conduit/settings.py`:

**Replace the DATABASES configuration:**

```python
import os

# PostgreSQL Database (replaces SQLite!)
DATABASES = {
    'default': {
        'ENGINE': os.environ.get('DATABASE_ENGINE', 'django.db.backends.postgresql'),
        'NAME': os.environ.get('DATABASE_NAME', 'conduit'),
        'USER': os.environ.get('DATABASE_USER', 'conduit'),
        'PASSWORD': os.environ.get('DATABASE_PASSWORD', ''),
        'HOST': os.environ.get('DATABASE_HOST', 'database'),
        'PORT': os.environ.get('DATABASE_PORT', '5432'),
        'CONN_MAX_AGE': 600,
    }
}
```

**Update ALLOWED_HOSTS:**

```python
# ALLOWED_HOSTS from environment
ALLOWED_HOSTS_ENV = os.environ.get('DJANGO_ALLOWED_HOSTS', 'localhost,127.0.0.1')
ALLOWED_HOSTS = [host.strip() for host in ALLOWED_HOSTS_ENV.split(',')]

# Add Docker service names (important for Nginx!)
ALLOWED_HOSTS.extend(['backend', 'conduit-backend'])
```

**Update SECRET_KEY:**

```python
# Secret Key from environment (required!)
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY')
if not SECRET_KEY:
    raise ValueError("DJANGO_SECRET_KEY environment variable must be set!")
```

**Update DEBUG:**

```python
# Debug mode
DEBUG = os.environ.get('DJANGO_DEBUG', 'False').lower() in ('true', '1', 'yes')
```

**Add CORS (if not already present):**

Add to `INSTALLED_APPS`:
```python
INSTALLED_APPS = [
    # ...
    'corsheaders',
]
```

Add to `MIDDLEWARE` (at the top!):
```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    # ... rest
]
```

Add CORS configuration:
```python
# CORS
CORS_ALLOWED_ORIGINS_ENV = os.environ.get('CORS_ALLOWED_ORIGINS', 'http://localhost:8282')
CORS_ALLOWED_ORIGINS = [origin.strip() for origin in CORS_ALLOWED_ORIGINS_ENV.split(',')]
CORS_ALLOW_CREDENTIALS = True
```

**Add Static/Media files configuration:**

```python
# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Media files (User uploads)
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'mediafiles')
```

### Environment Configuration

**Create .env file:**

```bash
cp .env.example .env
nano .env
```

**Required settings:**

```bash
# PostgreSQL (MUST be set!)
POSTGRES_PASSWORD=your_secure_password_here

# Django Secret Key (generate it!)
DJANGO_SECRET_KEY=your_generated_secret_key_here

# Your VM IP (replace YOUR_VM_IP_HERE!)
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,backend,conduit-backend,<YOUR_VM_IP_HERE>
CORS_ALLOWED_ORIGINS=http://localhost:8282,http://<YOUR_VM_IP_HERE>:8282
```

**Generate Django Secret Key:**

```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### Building and Running

**Build and start all services:**

```bash
docker compose up -d --build
```

### Access application
Frontend: http://<YOUR_VM_IP>:8282
Backend:  http://<YOUR_VM_IP>:8000/admin or http://<YOUR_VM_IP>:8000/api

**View logs:**

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend
```

**Check status:**

```bash
docker compose ps
```

**Stop services:**
# Stop (keeps data)
```bash
docker compose stop
```

# Stop and remove containers (keeps volumes)
```bash
docker compose down
```

# Stop and remove everything including data

> [!WARNING]  
> Deletes database!

```bash
docker compose down -v
```

### Logs

**View logs:**

```bash
# All services
docker compose logs

# Follow live
docker compose logs -f

# Specific service
docker compose logs backend
docker compose logs frontend
docker compose logs database
```

**Save logs to file:**

```bash
# Backend logs
docker logs conduit-backend > backend-logs.txt

# Frontend logs
docker logs conduit-frontend > frontend-logs.txt

# Database logs
docker logs conduit-postgres > database-logs.txt

# All logs with timestamps
docker compose logs --timestamps > all-logs.txt
```

---

### Database

**PostgreSQL configuration (.env):**

```bash
POSTGRES_DB=conduit
POSTGRES_USER=conduit
POSTGRES_PASSWORD=your_password
```

---

**Last Updated:** December 2025 <br>
**Course:** DevSecOps <br>
**Project:** Conduit Containerization <br>
