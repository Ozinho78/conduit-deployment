# PowerShell Deploy Script
# Kopiert Docker-Konfigurationsdateien in die geklonten Repos

Write-Host "==> Starting Conduit Deployment Setup" -ForegroundColor Green

# Konfiguration - Passe diese Pfade an!
$DEPLOY_DIR = $PSScriptRoot  # Aktuelles Verzeichnis (wo das Skript liegt)
$BACKEND_REPO = Join-Path $DEPLOY_DIR "conduit-backend"
$FRONTEND_REPO = Join-Path $DEPLOY_DIR "conduit-frontend"

# Prüfe ob Repos existieren
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
Write-Host "`n==> Kopiere Backend-Dateien..." -ForegroundColor Cyan

$backendFiles = @{
    "backend.Dockerfile" = "Dockerfile"
    "entrypoint.sh" = "entrypoint.sh"
    "backend.dockerignore" = ".dockerignore"
}

foreach ($source in $backendFiles.Keys) {
    $destination = $backendFiles[$source]
    $sourcePath = Join-Path $DEPLOY_DIR $source
    $destPath = Join-Path $BACKEND_REPO $destination
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ $source -> backend/$destination" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Datei nicht gefunden: $source" -ForegroundColor Red
    }
}

# Frontend-Dateien kopieren
Write-Host "`n==> Kopiere Frontend-Dateien..." -ForegroundColor Cyan

$frontendFiles = @{
    "frontend.Dockerfile" = "Dockerfile"
    "nginx-frontend.conf" = "nginx-frontend.conf"
    "frontend.dockerignore" = ".dockerignore"
}

foreach ($source in $frontendFiles.Keys) {
    $destination = $frontendFiles[$source]
    $sourcePath = Join-Path $DEPLOY_DIR $source
    $destPath = Join-Path $FRONTEND_REPO $destination
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ $source -> frontend/$destination" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Datei nicht gefunden: $source" -ForegroundColor Red
    }
}

# Berechtigungen für entrypoint.sh setzen (für WSL/Git Bash)
Write-Host "`n==> Setze Berechtigungen..." -ForegroundColor Cyan
$entrypointPath = Join-Path $BACKEND_REPO "entrypoint.sh"
if (Test-Path $entrypointPath) {
    # Git bash command für Berechtigungen (funktioniert wenn Git installiert ist)
    try {
        & git update-index --chmod=+x "$entrypointPath" 2>$null
        Write-Host "  ✓ entrypoint.sh ist ausführbar" -ForegroundColor Green
    } catch {
        Write-Host "  ! Git nicht verfügbar - Berechtigungen manuell in WSL/Linux setzen" -ForegroundColor Yellow
    }
}

Write-Host "`n==> Deployment-Setup abgeschlossen!" -ForegroundColor Green
Write-Host "`nNächste Schritte:" -ForegroundColor Cyan
Write-Host "  1. docker compose build" -ForegroundColor White
Write-Host "  2. docker compose up -d" -ForegroundColor White
Write-Host "  3. docker compose logs -f" -ForegroundColor White
