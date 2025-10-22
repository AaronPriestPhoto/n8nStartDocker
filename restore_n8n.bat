@echo off
setlocal ENABLEDELAYEDEXPANSION
pushd "%~dp0"

set "TITLE=n8n Restore"
echo ==============================================
echo %TITLE%
echo ==============================================
echo Available backups in this folder:
echo.

dir /b /o-d n8n_backup_*.tar.gz
if errorlevel 1 (
    echo No backup archives found in this folder.
    pause & popd & exit /b 1
)

echo(
set /p "backupfile=Enter exact backup filename to restore (or Q to cancel): "
if /i "%backupfile%"=="Q" popd & exit /b 0

if not exist "%backupfile%" (
    echo [ERROR] File "%backupfile%" not found!
    pause & popd & exit /b 1
)

echo(
echo === %TITLE%: Confirm restore from %backupfile% ===
echo This will overwrite your current n8n data volume!
set /p "confirm=Type YES to continue: "
if /i not "%confirm%"=="YES" (
    echo Restore cancelled.
    pause & popd & exit /b 0
)

echo(
echo === %TITLE%: Stopping containers ===
docker compose down || (echo [ERROR] Failed to stop containers & pause & popd & exit /b 1)

echo(
echo === %TITLE%: Restoring data from backup ===
docker run --rm -v n8n_data:/data -v "%CD%:/backup" busybox sh -c "rm -rf /data/* && tar xzf /backup/%backupfile% -C /"

echo(
echo === %TITLE%: Restarting containers ===
docker compose up -d || (echo [ERROR] Failed to start containers & pause & popd & exit /b 1)

echo(
echo === %TITLE%: Done! Opening dashboard... ===
start "" "http://localhost:5678/"
docker compose ps
popd
pause
exit /b 0
