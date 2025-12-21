Write-Host "==> Starting Conduit Deployment Setup" -ForegroundColor Green

$DEPLOY_DIR = $PSScriptRoot
$BACKEND_REPO = Join-Path $DEPLOY_DIR "conduit-backend"
$FRONTEND_REPO = Join-Path $DEPLOY_DIR "conduit-frontend"

if (-not (Test-Path $BACKEND_REPO)) {
    Write-Host "ERROR: Backend repo not found: $BACKEND_REPO" -ForegroundColor Red
    Write-Host "Please clone backend repo first" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $FRONTEND_REPO)) {
    Write-Host "ERROR: Frontend repo not found: $FRONTEND_REPO" -ForegroundColor Red
    Write-Host "Please clone frontend repo first" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "==> Copying backend files..." -ForegroundColor Cyan

$backendFiles = @{
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
        Write-Host "  Not found $source" -ForegroundColor Red
    }
}

# Frontend-Dateien kopieren
Write-Host ""
Write-Host "==> Copying frontend files..." -ForegroundColor Cyan

$frontendFiles = @{
    "frontend.dockerignore" = ".dockerignore"
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
        Write-Host "  Not found $source" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==> Setting permissions..." -ForegroundColor Cyan
$entrypointPath = Join-Path $BACKEND_REPO "entrypoint.sh"

if (Test-Path $entrypointPath) {
    Write-Host "  OK entrypoint.sh founde" -ForegroundColor Green
    Write-Host "  Hint: Please ensure that entrypoint.sh has UNIX file ending (LF)!" -ForegroundColor Yellow
} else {
    Write-Host "  Not found entrypoint.sh" -ForegroundColor Red
}

Write-Host ""
Write-Host "==> Deployment-Setup finished!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. docker compose build"
Write-Host "  2. docker compose up -d"
Write-Host "  3. docker compose logs -f"