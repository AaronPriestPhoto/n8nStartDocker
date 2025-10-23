@echo off
setlocal ENABLEDELAYEDEXPANSION
pushd "%~dp0"

set "TITLE=n8n"
echo ==============================================
echo %TITLE% - Docker controls
echo ==============================================
echo [U] Backup + Update/Start (no downtime)
echo [D] Shut Down (graceful + down)
echo [Q] Quit
echo(
set /p "CHOICE=Choose an option [U/D/Q]: "
if /i "%CHOICE%"=="Q" popd & exit /b 0

REM === Prevent double execution (lock) ===
set "LOCK=%TEMP%\n8n.lock"
if exist "%LOCK%" (
    echo [!] Another n8n.bat session seems active. Please close it first.
    pause
    popd
    exit /b 1
)
echo >"%LOCK%"

REM === Ensure Docker is running ===
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
            del "%LOCK%" >nul 2>&1
            pause & popd & exit /b 1
        )
        goto :wait_engine_n8n
    )
)

if /i "%CHOICE%"=="U" goto :update_start
if /i "%CHOICE%"=="D" goto :down_all

echo Invalid choice.
del "%LOCK%" >nul 2>&1
popd
pause
exit /b 1


:update_start
rem === Create safe timestamp (cross-version Windows) ===
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd_HHmm\")"') do set stamp=%%i

echo(
echo === %TITLE%: Creating volume backup before update ===
docker run --rm -v n8n_data:/data -v "%CD%:/backup" busybox sh -c "tar czf /backup/n8n_backup_%stamp%.tar.gz /data"

if not exist "n8n_backup_%stamp%.tar.gz" (
    echo [ERROR] Backup file missing! Aborting update.
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)

echo -> Verifying backup integrity...
tar -tzf "n8n_backup_%stamp%.tar.gz" >nul 2>&1 || (
    echo [ERROR] Backup archive corrupted. Aborting.
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)
echo Backup OK: n8n_backup_%stamp%.tar.gz

echo -> Cleaning old backups (keeping 7 most recent)...
for /f "skip=7 delims=" %%F in ('dir /b /o-d n8n_backup_*.tar.gz') do del "%%F"

echo(
echo === %TITLE%: Pulling latest n8n image ===
docker compose pull || (echo [ERROR] pull failed & del "%LOCK%" & pause & popd & exit /b 1)

echo(
echo === %TITLE%: Starting/updating containers ===
docker compose up -d || (echo [ERROR] up failed & del "%LOCK%" & pause & popd & exit /b 1)

echo(
echo -> Pruning unused images...
docker image prune -f >nul 2>&1

echo(
echo === %TITLE%: Done! Opening dashboard... ===
docker compose ps
start "" "http://localhost:5678/"

del "%LOCK%" >nul 2>&1
popd
pause
exit /b 0


:down_all
echo(
echo === %TITLE%: Gracefully stopping containers ===
docker compose stop -t 30

echo === %TITLE%: Shutting down compose project ===
docker compose down --remove-orphans || (
    echo [ERROR] down failed
    del "%LOCK%" >nul 2>&1
    pause & popd & exit /b 1
)

echo(
echo === %TITLE%: All containers stopped and removed. ===
del "%LOCK%" >nul 2>&1
popd
pause
exit /b 0
