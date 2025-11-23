@echo off
REM LINE Opener for Edge - 解除安裝程式

echo ========================================
echo   LINE Opener for Edge - 解除安裝
echo ========================================
echo.

set INSTALL_DIR=%LOCALAPPDATA%\LineOpener

echo [1/2] 移除協定註冊...
reg delete "HKCU\Software\Classes\openline" /f >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo       協定已移除
) else (
    echo       協定不存在或已移除
)
echo.

echo [2/2] 刪除安裝檔案...
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
    echo       檔案已刪除: %INSTALL_DIR%
) else (
    echo       安裝目錄不存在
)
echo.

echo ========================================
echo   解除安裝完成！
echo ========================================
echo.
echo 請手動移除 Chrome 擴充程式:
echo 1. 前往 chrome://extensions/
echo 2. 找到「Open LINE in Edge」
echo 3. 點擊「移除」
echo.
pause
