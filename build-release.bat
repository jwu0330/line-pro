@echo off
REM 建立發佈版本

echo ========================================
echo   建立 LINE Opener Pro 發佈版本
echo ========================================
echo.

set VERSION=v2.1.0
set OUTPUT_DIR=release
set ZIP_NAME=line-pro-installer.zip

echo [1/3] 清理舊版本...
if exist "%OUTPUT_DIR%" rmdir /S /Q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"
echo.

echo [2/3] 複製檔案...
REM 建立資料夾結構
mkdir "%OUTPUT_DIR%\line-pro"
mkdir "%OUTPUT_DIR%\line-pro\icons"
mkdir "%OUTPUT_DIR%\line-pro\native-host"

REM 複製擴充程式檔案
copy manifest.json "%OUTPUT_DIR%\line-pro\" >nul
copy popup.html "%OUTPUT_DIR%\line-pro\" >nul
copy popup.js "%OUTPUT_DIR%\line-pro\" >nul
copy background.js "%OUTPUT_DIR%\line-pro\" >nul
copy icons\*.png "%OUTPUT_DIR%\line-pro\icons\" >nul

REM 複製 Native Host 檔案
copy native-host\*.bat "%OUTPUT_DIR%\line-pro\native-host\" >nul
copy native-host\*.ps1 "%OUTPUT_DIR%\line-pro\native-host\" >nul
copy native-host\*.json "%OUTPUT_DIR%\line-pro\native-host\" >nul

REM 複製安裝/解除安裝程式
copy install-pro.bat "%OUTPUT_DIR%\line-pro\" >nul
copy uninstall-pro.bat "%OUTPUT_DIR%\line-pro\" >nul

REM 複製說明文件
copy README.md "%OUTPUT_DIR%\line-pro\" >nul
copy LICENSE "%OUTPUT_DIR%\line-pro\" >nul

echo       已複製所有檔案
echo.

echo [3/3] 建立 ZIP 檔案...
powershell -Command "Compress-Archive -Path '%OUTPUT_DIR%\line-pro\*' -DestinationPath '%OUTPUT_DIR%\%ZIP_NAME%' -Force"
echo       已建立 %ZIP_NAME%
echo.

echo ========================================
echo   建立完成！
echo ========================================
echo.
echo 輸出位置: %OUTPUT_DIR%\%ZIP_NAME%
echo 檔案大小: 
powershell -Command "(Get-Item '%OUTPUT_DIR%\%ZIP_NAME%').Length / 1KB | ForEach-Object { '{0:N2} KB' -f $_ }"
echo.
echo 下一步:
echo 1. 前往 GitHub 建立 Release
echo 2. 標籤: %VERSION%
echo 3. 上傳 %ZIP_NAME%
echo 4. 發佈！
echo.
pause
