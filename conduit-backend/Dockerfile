# Single-stage build as requested
FROM python:3.5-slim

# Environment configuration
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    GUNICORN_WORKERS=4 \
    GUNICORN_TIMEOUT=120 \
    LOG_LEVEL=info

WORKDIR /app

# Fix Debian Buster EOL repository issue
RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Install system dependencies (gcc for building psycopg2, libpq5 for runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    libpq5 \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip==20.3.4 && \
    pip install --no-cache-dir -r requirements.txt

# Create non-root user 'deploy' BEFORE copying application files
RUN useradd -m -u 1000 -s /bin/bash deploy

# Copy application code with correct ownership
COPY --chown=deploy:deploy . .

# Copy and set entrypoint permissions
COPY --chown=deploy:deploy entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create staticfiles directory with correct ownership and permissions
RUN mkdir -p /app/staticfiles && \
    chown -R deploy:deploy /app/staticfiles && \
    chmod -R 755 /app/staticfiles

# Ensure deploy user owns entire /app directory
RUN chown -R deploy:deploy /app

# Switch to non-root user
USER deploy

# Expose application port
EXPOSE 8000

# Start application via entrypoint
ENTRYPOINT ["/entrypoint.sh"]