# Native Host 診斷工具
Write-Host "========================================"
Write-Host "  Native Host 診斷工具"
Write-Host "========================================"
Write-Host ""

# 1. 檢查安裝目錄
$installDir = "$env:LOCALAPPDATA\LineOpenerPro\native-host"
Write-Host "[1] 檢查安裝目錄..."
if (Test-Path $installDir) {
    Write-Host "    OK - 目錄存在: $installDir"
    $files = Get-ChildItem $installDir
    Write-Host "    檔案列表:"
    foreach ($file in $files) {
        Write-Host "      - $($file.Name)"
    }
} else {
    Write-Host "    FAIL - 目錄不存在"
    exit 1
}
Write-Host ""

# 2. 檢查 manifest 檔案
Write-Host "[2] 檢查 manifest 檔案..."
$manifestPath = "$installDir\com.line.opener.json"
if (Test-Path $manifestPath) {
    Write-Host "    OK - manifest 檔案存在"
    $manifest = Get-Content $manifestPath -Raw
    Write-Host "    內容:"
    Write-Host $manifest
} else {
    Write-Host "    FAIL - manifest 檔案不存在"
    exit 1
}
Write-Host ""

# 3. 檢查註冊表
Write-Host "[3] 檢查註冊表..."
try {
    $regPath = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.line.opener"
    $regValue = Get-ItemProperty -Path $regPath -ErrorAction Stop
    $defaultValue = $regValue.'(default)'
    Write-Host "    OK - 註冊表項目存在"
    Write-Host "    路徑: $defaultValue"
} catch {
    Write-Host "    FAIL - 註冊表項目不存在"
    exit 1
}
Write-Host ""

# 4. 檢查 Extension ID
Write-Host "[4] 檢查 Extension ID..."
$manifestJson = $manifest | ConvertFrom-Json
$allowedOrigin = $manifestJson.allowed_origins[0]
Write-Host "    allowed_origins: $allowedOrigin"
Write-Host ""

Write-Host "========================================"
Write-Host "  診斷完成"
Write-Host "========================================"
Write-Host ""
Write-Host "如果所有檢查都通過，但 Chrome 仍顯示未安裝："
Write-Host "1. 完全關閉所有 Chrome 視窗"
Write-Host "2. 重新開啟 Chrome"
Write-Host "3. 前往 chrome://extensions/"
Write-Host "4. 找到擴充程式並點擊重新載入按鈕"
Write-Host "5. 點擊擴充圖示測試"
Write-Host ""
