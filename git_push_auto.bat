@echo off
chcp 65001 >nul
title GIT AUTO PUSH
echo Starting Git Auto Push...
echo.

REM Run PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0git_push_auto.ps1"

echo.
echo Git Auto Push finished.
echo Press any key to exit...
pause >nul
