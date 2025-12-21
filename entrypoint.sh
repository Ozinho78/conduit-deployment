#!/bin/sh

set -e

echo "==> Starting Conduit Backend"

echo "==> Waiting for database..."
if [ -n "${DB_HOST}" ]; then
    echo "==> Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT:-5432}..."
    
    max_retries=30
    retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if nc -z "${DB_HOST}" "${DB_PORT:-5432}" 2>/dev/null; then
            echo "==> PostgreSQL is ready!"
            break
        fi
        retry_count=$((retry_count + 1))
        echo "==> PostgreSQL not ready yet. Retry $retry_count/$max_retries..."
        sleep 1
    done
    
    if [ $retry_count -eq $max_retries ]; then
        echo "ERROR: Could not connect to PostgreSQL after $max_retries attempts"
        exit 1
    fi
else
    echo "==> Using SQLite (no DB_HOST specified)"
fi

echo "==> Running database migrations..."
python manage.py migrate --noinput

echo "==> Collecting static files..."
python manage.py collectstatic --noinput --clear || echo "Static files collection skipped"

echo "==> Starting Gunicorn WSGI Server on port ${PORT:-8000}"
exec gunicorn conduit.wsgi:application \
    --bind 0.0.0.0:${PORT:-8000} \
    --workers ${GUNICORN_WORKERS:-4} \
    --timeout ${GUNICORN_TIMEOUT:-120} \
    --access-logfile - \
    --error-logfile - \
    --log-level ${LOG_LEVEL:-info} \
    --capture-output \
    --enable-stdio-inheritance
