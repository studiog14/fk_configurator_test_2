@echo off
setlocal enabledelayedexpansion

REM === KONFIGURACJA ===
set REPO_PATH=D:\FK_Configurator
set REMOTE_REPO=https://github.com/studiog14/fajne_krzesla_configurator.git
set BRANCH=main
set MAX_SIZE_MB=1200

REM === PRZEJŚCIE DO FOLDERU REPO ===
cd /d "%REPO_PATH%"

echo -------------------------------------
echo 🚀  PUSHOWANIE ZMIAN DO GITHUBA (FORCE)
echo -------------------------------------

REM === SPRAWDZANIE DUŻYCH PLIKÓW ===
echo 🔍 Sprawdzanie dużych plików...
for /f "delims=" %%F in ('git ls-files -z ^| tr "\0" "\n"') do (
    if exist "%%F" (
        for /f "usebackq" %%S in (`powershell -command "(Get-Item '%%F').length / 1MB"`) do (
            if %%S gtr %MAX_SIZE_MB% (
                echo ⚠️  Pomijam duży plik: %%F (%%S MB)
                git update-index --assume-unchanged "%%F"
            )
        )
    )
)

REM === DODAWANIE I COMMITOWANIE ===
git add -A
set DATESTAMP=%date%_%time%
git commit -m "Auto push %DATESTAMP%" || echo (Brak zmian do commitowania)

REM === PUSH FORCE ===
git push "%REMOTE_REPO%" "%BRANCH%" --force

if %errorlevel%==0 (
    echo ✅ Zmiany wypchnięte pomyślnie!
) else (
    echo ❌ Wystąpił błąd podczas pushowania.
)

pause
