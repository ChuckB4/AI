@echo off
REM ============================================================
REM  Living Way UPC Outreach - Easy Launcher
REM  Don: just double-click this file. That's all you do.
REM ============================================================
title Living Way UPC Outreach
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0program\menu.ps1"
echo.
echo You can close this window now.
pause >nul
