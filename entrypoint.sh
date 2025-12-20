#!/bin/sh

set -e

echo "==> Starting Conduit Backend"

echo "==> Waiting for database connection..."
python << END
import sys
import time
from django.db import connections
from django.db.utils import OperationalError

max_retries = 30
retry_count = 0

while retry_count < max_retries:
    try:
        conn = connections['default']
        conn.ensure_connection()
        print("Database connection successful!")
        sys.exit(0)
    except OperationalError:
        retry_count += 1
        print(f"Database not ready yet. Retry {retry_count}/{max_retries}...")
        time.sleep(1)

print("Could not connect to database after maximum retries")
sys.exit(1)
END

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
