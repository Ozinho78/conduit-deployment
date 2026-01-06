FROM python:3.5-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000 \
    GUNICORN_WORKERS=4 \
    GUNICORN_TIMEOUT=120 \
    LOG_LEVEL=info

WORKDIR /app

RUN echo "deb http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    libpq5 \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip==20.3.4 && \
    pip install --no-cache-dir -r requirements.txt

RUN useradd -m -u 1000 -s /bin/bash deploy

COPY --chown=deploy:deploy . .

COPY --chown=deploy:deploy entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN chown -R deploy:deploy /app

USER deploy

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]