# PowerShell Deploy Script
# Kopiert Docker-Konfigurationsdateien in die geklonten Repos

Write-Host "==> Starting Conduit Deployment Setup" -ForegroundColor Green

# Konfiguration - Passe diese Pfade an!
$DEPLOY_DIR = $PSScriptRoot
$BACKEND_REPO = Join-Path $DEPLOY_DIR "conduit-backend"
$FRONTEND_REPO = Join-Path $DEPLOY_DIR "conduit-frontend"

# Pruefe ob Repos existieren
if (-not (Test-Path $BACKEND_REPO)) {
    Write-Host "ERROR: Backend-Repo nicht gefunden: $BACKEND_REPO" -ForegroundColor Red
    Write-Host "Klone zuerst das Backend-Repo!" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $FRONTEND_REPO)) {
    Write-Host "ERROR: Frontend-Repo nicht gefunden: $FRONTEND_REPO" -ForegroundColor Red
    Write-Host "Klone zuerst das Frontend-Repo!" -ForegroundColor Yellow
    exit 1
}

# Backend-Dateien kopieren
Write-Host ""
Write-Host "==> Kopiere Backend-Dateien..." -ForegroundColor Cyan

$backendFiles = @{
    # "backend.Dockerfile" = "backend.Dockerfile"
    # "nginx-backend.conf" = "nginx-backend.conf"
    "entrypoint.sh" = "entrypoint.sh"
    "backend.dockerignore" = ".dockerignore"
}

foreach ($source in $backendFiles.Keys) {
    $destination = $backendFiles[$source]
    $sourcePath = Join-Path $DEPLOY_DIR $source
    $destPath = Join-Path $BACKEND_REPO $destination
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  OK $source -> backend/$destination" -ForegroundColor Green
    } else {
        Write-Host "  FEHLT $source" -ForegroundColor Red
    }
}

# Frontend-Dateien kopieren
Write-Host ""
Write-Host "==> Kopiere Frontend-Dateien..." -ForegroundColor Cyan

$frontendFiles = @{
    "frontend.dockerignore" = ".dockerignore"
    # "frontend.Dockerfile" = "frontend.Dockerfile"
    "nginx-frontend.conf" = "nginx-frontend.conf"
}

foreach ($source in $frontendFiles.Keys) {
    $destination = $frontendFiles[$source]
    $sourcePath = Join-Path $DEPLOY_DIR $source
    $destPath = Join-Path $FRONTEND_REPO $destination
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  OK $source -> frontend/$destination" -ForegroundColor Green
    } else {
        Write-Host "  FEHLT $source" -ForegroundColor Red
    }
}

# Berechtigungen fuer entrypoint.sh
Write-Host ""
Write-Host "==> Setze Berechtigungen..." -ForegroundColor Cyan
$entrypointPath = Join-Path $BACKEND_REPO "entrypoint.sh"

if (Test-Path $entrypointPath) {
    Write-Host "  OK entrypoint.sh gefunden" -ForegroundColor Green
    Write-Host "  HINWEIS: Stelle sicher dass entrypoint.sh Unix-Zeilenenden (LF) hat!" -ForegroundColor Yellow
} else {
    Write-Host "  FEHLT entrypoint.sh" -ForegroundColor Red
}

Write-Host ""
Write-Host "==> Deployment-Setup abgeschlossen!" -ForegroundColor Green
Write-Host ""
Write-Host "Naechste Schritte:" -ForegroundColor Cyan
Write-Host "  1. docker compose build"
Write-Host "  2. docker compose up -d"
Write-Host "  3. docker compose logs -f"