@echo off
chcp 65001 >nul
title GIT AUTO PUSH (PROJECT / CHAIRS / TEXTURES)
echo =========================================
echo   GIT AUTO PUSH (PROJECT / CHAIRS / TEXTURES)
echo =========================================
echo.

REM ------------------------------
REM SETTINGS
REM ------------------------------
set REPO_PATH=D:\FK_Configurator
set MAX_SIZE_MB=100
set RETRY_LIMIT=3
set LARGE_FILE_LOG=%REPO_PATH%\large_files_report.txt

REM ------------------------------
REM Move to repo
REM ------------------------------
cd /d "%REPO_PATH%"

REM ------------------------------
REM Clear previous large file report
REM ------------------------------
if exist "%LARGE_FILE_LOG%" del "%LARGE_FILE_LOG%"

REM =====================================================
REM CALL POWERSHELL FOR LARGE FILE CHECK AND PUSH
REM =====================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Set-Location '%REPO_PATH%'; ^
$MaxSizeBytes = %MAX_SIZE_MB%*1MB; ^
$RetryLimit = %RETRY_LIMIT%; ^
$LargeFileLog = '%LARGE_FILE_LOG%'; ^
Write-Host 'Checking for files above %MAX_SIZE_MB% MB...'; ^
Write-Host '-------------------------------------'; ^
$Files = git ls-files; ^
foreach ($file in $Files) { ^
    $fileTrim = $file.Trim(); ^
    if ([string]::IsNullOrWhiteSpace($fileTrim)) { continue }; ^
    if (Test-Path $fileTrim) { ^
        $size = (Get-Item -LiteralPath $fileTrim).Length; ^
        if ($size -gt $MaxSizeBytes) { ^
            $sizeMB = [math]::Round($size/1MB,2); ^
            Write-Host '⚠️ LARGE FILE DETECTED:'; ^
            Write-Host '   Path: ' $fileTrim; ^
            Write-Host '   Size: ' $sizeMB ' MB'; ^
            Add-Content -Path $LargeFileLog -Value ($fileTrim + '  ' + $sizeMB + ' MB'); ^
        } ^
    } ^
}; ^
function Push-WithRetry($Folder, $Msg) { ^
    $Attempt = 1; ^
    do { ^
        Write-Host '🔹 [' + $Folder + '] Pushing: ' + $Msg + ' (Attempt #' + $Attempt + ')'; ^
        git add $Folder -f; ^
        git commit -m $Msg -ErrorAction SilentlyContinue; ^
        try { ^
            git push origin main --force; ^
            if ($LASTEXITCODE -eq 0) { Write-Host '✅ Push of ' + $Folder + ' (' + $Msg + ') successful!'; Write-Host '-------------------------------------'; return }; ^
            throw 'Push failed with code ' + $LASTEXITCODE; ^
        } catch { ^
            Write-Host '❌ Push of ' + $Folder + ' (' + $Msg + ') failed: ' + $_; ^
            if ($Attempt -ge %RETRY_LIMIT%) { Write-Host '❌ Giving up after %RETRY_LIMIT% attempts.'; Write-Host '-------------------------------------'; exit 1 }; ^
            Write-Host '🔁 Retrying in 10 seconds...'; ^
            Start-Sleep -Seconds 10; ^
            $Attempt++; ^
        }; ^
    } while ($Attempt -le %RETRY_LIMIT%); ^
}; ^
Write-Host ''; ^
Write-Host '🧱 Step 1: Pushing project core files (HTML, JS, CSS)...'; ^
git add . -f; git reset chairs/ textures/ | Out-Null; git commit -m 'Push core project files' -ErrorAction SilentlyContinue; ^
Push-WithRetry '.' 'Push core project files'; ^
Write-Host ''; ^
Write-Host '🪑 Step 2: Pushing CHAIRS folder...'; ^
Push-WithRetry 'chairs' 'Push chairs models'; ^
Write-Host ''; ^
Write-Host '🎨 Step 3: Pushing TEXTURES folder...'; ^
Push-WithRetry 'textures' 'Push textures'; ^
Write-Host ''; ^
Write-Host '========================================='; ^
Write-Host '✅ All push steps completed successfully!'; ^
Write-Host '========================================='; ^
Write-Host 'Large files report saved to %LARGE_FILE_LOG%'; ^
Write-Host ''; ^
Write-Host 'Press any key to exit...'; ^
$x = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');"

