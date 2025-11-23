@echo off
REM Auto-click Edge LINE extension icon using UI Automation
REM This file will be installed to %LOCALAPPDATA%\LineOpener\

REM 取得此批次檔的目錄（安裝後會在 %LOCALAPPDATA%\LineOpener\）
set SCRIPT_DIR=%~dp0

REM 執行 PowerShell 腳本（完全隱藏視窗）
start /B powershell -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -NonInteractive -File "%SCRIPT_DIR%auto_click_final.ps1"

exit /b 0
