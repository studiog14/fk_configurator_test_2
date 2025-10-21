@echo off
chcp 65001 >nul
title GIT PUSH SPLIT (fajne_krzesla_configurator)
echo =========================================
echo   GIT PUSH SPLIT (PROJECT / CHAIRS / TEXTURES)
echo =========================================
echo.

cd /d "D:\FK_Configurator"

REM -------------------------------------
REM Function to check large files
REM -------------------------------------
set MAX_SIZE_MB=1200
set MAX_SIZE_BYTES=1258291200

echo Checking for large files above %MAX_SIZE_MB% MB...
echo -------------------------------------
for /f "delims=" %%f in ('git ls-files') do (
    if exist "%%f" (
        for %%I in ("%%f") do (
            set size=%%~zI
            call :checksize "%%f" %%~zI
        )
    )
)
goto :afterCheck

:checksize
setlocal
set "file=%~1"
set "size=%~2"
if %size% GTR %MAX_SIZE_BYTES% (
    echo WARNING: Large file detected - %file%
)
endlocal
exit /b

:afterCheck
echo -------------------------------------
echo.

REM ========== 1️⃣ PUSH PROJECT FILES (excluding chairs, textures) ==========
echo 🔹 Step 1: Push project core files...
echo -------------------------------------
git add . -f
git reset chairs/ textures/ >nul 2>&1
git commit -m "Push core project files" || echo (No changes to commit)
git push origin main --force
echo -------------------------------------
echo.

REM ========== 2️⃣ PUSH CHAIRS ==========
echo 🔹 Step 2: Push chairs folder...
echo -------------------------------------
git add chairs -f
git commit -m "Push chairs models" || echo (No changes to commit)
git push origin main --force
echo -------------------------------------
echo.

REM ========== 3️⃣ PUSH TEXTURES ==========
echo 🔹 Step 3: Push textures folder...
echo -------------------------------------
git add textures -f
git commit -m "Push textures" || echo (No changes to commit)
git push origin main --force
echo -------------------------------------
echo.

echo ✅ All push steps finished.
pause
exit /b
