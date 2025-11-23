@echo off
REM Native Messaging Host - 批次檔版本
REM 不需要 Python，直接用 PowerShell 處理

REM 呼叫 PowerShell 處理 Native Messaging 協定
powershell -ExecutionPolicy Bypass -NoProfile -NonInteractive -File "%~dp0line_opener_host.ps1"
