#!/bin/bash
set -e

echo "Waiting for PostgreSQL to be ready..."
while ! nc -z ${DATABASE_HOST} ${DATABASE_PORT}; do
    sleep 0.5
done
echo "PostgreSQL is ready!"

echo "Running database migrations..."
python manage.py migrate --noinput

echo "Starting Gunicorn WSGI server..."
exec gunicorn conduit.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 4 \
    --threads 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile - \
    --log-level info
