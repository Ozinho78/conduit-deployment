#!/bin/bash

set -e

echo -e "\033[0;32m==> Starting Conduit Deployment Setup\033[0m"

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_REPO="${DEPLOY_DIR}/conduit-backend"
FRONTEND_REPO="${DEPLOY_DIR}/conduit-frontend"

if [ ! -d "${BACKEND_REPO}" ]; then
    echo -e "\033[0;31mERROR: Backend repo not found: ${BACKEND_REPO}\033[0m"
    echo -e "\033[0;33mPlease clone backend repo first!\033[0m"
    exit 1
fi

if [ ! -d "${FRONTEND_REPO}" ]; then
    echo -e "\033[0;31mERROR: Frontend repo not found: ${BACKEND_REPO}\033[0m"
    echo -e "\033[0;33mPlease clone frontend repo first!\033[0m"
    exit 1
fi

echo -e "\n\033[0;36m==> Copying backend files...\033[0m"

declare -A backend_files=(
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
        echo -e "  \033[0;31m✗\033[0m File not found: ${source}"
    fi
done

echo -e "\n\033[0;36m==> Copying frontend files...\033[0m"

declare -A frontend_files=(
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
        echo -e "  \033[0;31m✗\033[0m File not found: ${source}"
    fi
done

echo -e "\n\033[0;36m==> Setting permissions...\033[0m"
entrypoint_path="${BACKEND_REPO}/entrypoint.sh"
if [ -f "${entrypoint_path}" ]; then
    chmod +x "${entrypoint_path}"
    echo -e "  \033[0;32m✓\033[0m entrypoint.sh is executable"
fi

echo -e "\n\033[0;32m==> Deployment-Setup finished!\033[0m"
echo -e "\n\033[0;36mNächste Schritte:\033[0m"
echo -e "  \033[0;37m1. docker compose build\033[0m"
echo -e "  \033[0;37m2. docker compose up -d\033[0m"
echo -e "  \033[0;37m3. docker compose logs -f\033[0m"
