@echo off
REM LINE Opener Pro - 解除安裝

echo ========================================
echo   LINE Opener Pro - 解除安裝
echo ========================================
echo.

set INSTALL_DIR=%LOCALAPPDATA%\LineOpenerPro

echo [1/2] 移除 Native Messaging Host 註冊...
reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Edge\NativeMessagingHosts\com.line.opener" /f >nul 2>&1
echo       已移除
echo.

echo [2/2] 刪除安裝檔案...
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
    echo       已刪除: %INSTALL_DIR%
) else (
    echo       安裝目錄不存在
)
echo.

echo ========================================
echo   解除安裝完成！
echo ========================================
echo.
echo 請手動移除 Chrome 擴充程式
echo.
pause
