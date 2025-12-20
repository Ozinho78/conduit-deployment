#!/bin/bash

# Bash Deploy Script
# Kopiert Docker-Konfigurationsdateien in die geklonten Repos

set -e

echo -e "\033[0;32m==> Starting Conduit Deployment Setup\033[0m"

# Konfiguration - Passe diese Pfade an!
DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_REPO="${DEPLOY_DIR}/conduit-backend"
FRONTEND_REPO="${DEPLOY_DIR}/conduit-frontend"

# Prüfe ob Repos existieren
if [ ! -d "${BACKEND_REPO}" ]; then
    echo -e "\033[0;31mERROR: Backend-Repo nicht gefunden: ${BACKEND_REPO}\033[0m"
    echo -e "\033[0;33mKlone zuerst das Backend-Repo!\033[0m"
    exit 1
fi

if [ ! -d "${FRONTEND_REPO}" ]; then
    echo -e "\033[0;31mERROR: Frontend-Repo nicht gefunden: ${FRONTEND_REPO}\033[0m"
    echo -e "\033[0;33mKlone zuerst das Frontend-Repo!\033[0m"
    exit 1
fi

# Backend-Dateien kopieren
echo -e "\n\033[0;36m==> Kopiere Backend-Dateien...\033[0m"

declare -A backend_files=(
    ["backend.Dockerfile"]="Dockerfile"
    ["entrypoint.sh"]="entrypoint.sh"
    ["backend.dockerignore"]=".dockerignore"
)

for source in "${!backend_files[@]}"; do
    destination="${backend_files[$source]}"
    source_path="${DEPLOY_DIR}/${source}"
    dest_path="${BACKEND_REPO}/${destination}"
    
    if [ -f "${source_path}" ]; then
        cp "${source_path}" "${dest_path}"
        echo -e "  \033[0;32m✓\033[0m ${source} -> backend/${destination}"
    else
        echo -e "  \033[0;31m✗\033[0m Datei nicht gefunden: ${source}"
    fi
done

# Frontend-Dateien kopieren
echo -e "\n\033[0;36m==> Kopiere Frontend-Dateien...\033[0m"

declare -A frontend_files=(
    ["frontend.Dockerfile"]="Dockerfile"
    ["nginx-frontend.conf"]="nginx-frontend.conf"
    ["frontend.dockerignore"]=".dockerignore"
)

for source in "${!frontend_files[@]}"; do
    destination="${frontend_files[$source]}"
    source_path="${DEPLOY_DIR}/${source}"
    dest_path="${FRONTEND_REPO}/${destination}"
    
    if [ -f "${source_path}" ]; then
        cp "${source_path}" "${dest_path}"
        echo -e "  \033[0;32m✓\033[0m ${source} -> frontend/${destination}"
    else
        echo -e "  \033[0;31m✗\033[0m Datei nicht gefunden: ${source}"
    fi
done

# Berechtigungen für entrypoint.sh setzen
echo -e "\n\033[0;36m==> Setze Berechtigungen...\033[0m"
entrypoint_path="${BACKEND_REPO}/entrypoint.sh"
if [ -f "${entrypoint_path}" ]; then
    chmod +x "${entrypoint_path}"
    echo -e "  \033[0;32m✓\033[0m entrypoint.sh ist ausführbar"
fi

echo -e "\n\033[0;32m==> Deployment-Setup abgeschlossen!\033[0m"
echo -e "\n\033[0;36mNächste Schritte:\033[0m"
echo -e "  \033[0;37m1. docker compose build\033[0m"
echo -e "  \033[0;37m2. docker compose up -d\033[0m"
echo -e "  \033[0;37m3. docker compose logs -f\033[0m"
