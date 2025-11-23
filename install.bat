@echo off
REM LINE Opener for Edge - 安裝程式
REM 自動設定協定和複製檔案到使用者目錄

echo ========================================
echo   LINE Opener for Edge - 安裝程式
echo ========================================
echo.

REM 設定安裝目錄（使用者本地目錄，不需要管理員權限）
set INSTALL_DIR=%LOCALAPPDATA%\LineOpener
set SCRIPT_DIR=%~dp0

echo [1/4] 建立安裝目錄...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
echo       目錄: %INSTALL_DIR%
echo.

echo [2/4] 複製檔案...
copy /Y "%SCRIPT_DIR%auto_click_final.ps1" "%INSTALL_DIR%\" >nul
copy /Y "%SCRIPT_DIR%open_line_in_edge.bat" "%INSTALL_DIR%\" >nul
echo       已複製 auto_click_final.ps1
echo       已複製 open_line_in_edge.bat
echo.

echo [3/4] 註冊 openline:// 協定...
reg add "HKCU\Software\Classes\openline" /ve /t REG_SZ /d "URL:Open LINE in Edge Protocol" /f >nul
reg add "HKCU\Software\Classes\openline" /v "URL Protocol" /t REG_SZ /d "" /f >nul
reg add "HKCU\Software\Classes\openline\shell\open\command" /ve /t REG_SZ /d "\"%INSTALL_DIR%\open_line_in_edge.bat\"" /f >nul
echo       協定已註冊
echo.

echo [4/4] 更新批次檔路徑...
REM 更新 open_line_in_edge.bat 中的路徑
powershell -Command "(Get-Content '%INSTALL_DIR%\open_line_in_edge.bat') -replace 'set SCRIPT_DIR=.*', 'set SCRIPT_DIR=%INSTALL_DIR%\' | Set-Content '%INSTALL_DIR%\open_line_in_edge.bat'" >nul
echo       路徑已更新
echo.

echo ========================================
echo   安裝完成！
echo ========================================
echo.
echo 安裝位置: %INSTALL_DIR%
echo.
echo 下一步:
echo 1. 在 Chrome 載入擴充程式（開發人員模式）
echo 2. 點擊擴充圖示測試
echo.
echo 第一次使用時，請在確認對話框點擊「開啟」
echo 之後就會自動執行，不再詢問。
echo.
pause
