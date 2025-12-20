# ============================================================================
# Backend Dockerfile - Django + Gunicorn + PostgreSQL
# ============================================================================
# Multi-Stage Build für optimale Image-Größe
# ============================================================================

# ----------------------------------------------------------------------------
# Stage 1: Builder - Dependencies installieren
# ----------------------------------------------------------------------------
FROM python:3.5-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

# Debian Archive Repositories (für Python 3.5)
RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Build Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Pip upgrade
RUN pip install --upgrade pip==20.3.4

# Python Dependencies
COPY requirements.txt .
# COPY conduit-backend/requirements.txt .
RUN pip install --no-cache-dir \
    -r requirements.txt \
    gunicorn==19.9.0 \
    psycopg2-binary==2.7.7

# ----------------------------------------------------------------------------
# Stage 2: Runtime - Production Image
# ----------------------------------------------------------------------------
FROM python:3.5-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

# Debian Archive Repositories
RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Runtime Dependencies (nur PostgreSQL Client)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Python packages von Builder kopieren
COPY --from=builder /usr/local/lib/python3.5/site-packages /usr/local/lib/python3.5/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Application Code
COPY . .
# COPY conduit-backend/ .

# Static & Media Files Directories
RUN mkdir -p /app/staticfiles /app/mediafiles

# Static Files sammeln (CSS, JS, Admin Assets)
# WICHTIG: Diese werden später von Nginx ausgeliefert!
RUN python manage.py collectstatic --noinput --clear || echo "collectstatic skipped"

# Non-root User
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE ${PORT}

# Health Check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:${PORT}/api/health').read()" || exit 1

# Gunicorn WSGI Server (Checklist Requirement!)
# KEIN Development Server!
CMD ["sh", "-c", "python manage.py migrate --noinput && gunicorn conduit.wsgi:application --bind 0.0.0.0:${PORT} --workers 4 --timeout 120 --access-logfile - --error-logfile -"]
