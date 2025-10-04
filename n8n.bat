@echo off
setlocal ENABLEDELAYEDEXPANSION
pushd "%~dp0"

set "TITLE=n8n"
echo ==============================================
echo %TITLE% - Docker controls
echo ==============================================
echo [U] Update/Start (no downtime)
echo [D] Shut Down (docker compose down)
echo [Q] Quit
echo(
set /p "CHOICE=Choose an option [U/D/Q]: "
if /i "%CHOICE%"=="Q" popd & exit /b 0

REM Ensure Docker is up (for U/D)
docker info >nul 2>&1
if errorlevel 1 (
    echo Docker not ready. Starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" 2>nul
    echo Waiting for Docker Engine to be ready...
    set /a retries=0
    :wait_engine_n8n
    timeout /t 2 /nobreak >nul
    docker info >nul 2>&1
    if errorlevel 1 (
        set /a retries+=1
        if !retries! GEQ 150 (
            echo [ERROR] Docker Engine did not become ready within ~5 minutes. Exiting.
            pause & popd & exit /b 1
        )
        goto :wait_engine_n8n
    )
)

if /i "%CHOICE%"=="U" goto :update_start
if /i "%CHOICE%"=="D" goto :down_all

echo Invalid choice.
popd
pause
exit /b 1

:update_start
echo(
echo === %TITLE%: Pulling latest images ===
docker compose pull || (echo [ERROR] pull failed & pause & popd & exit /b 1)

echo(
echo === %TITLE%: Starting/updating containers ===
docker compose up -d || (echo [ERROR] up failed & pause & popd & exit /b 1)

echo(
echo -> Pruning unused images...
docker image prune -f >nul 2>&1

echo(
echo === %TITLE%: Done! Opening dashboard... ===
start "" "http://localhost:5678/"
echo(
docker compose ps
popd
pause
exit /b 0

:down_all
echo(
echo === %TITLE%: Shutting down compose project (docker compose down) ===
docker compose down || (echo [ERROR] down failed & pause & popd & exit /b 1)
echo(
echo NOTE: Volumes/images are kept. To remove volumes too, run:
echo   docker compose down -v
popd
pause
exit /b 0
