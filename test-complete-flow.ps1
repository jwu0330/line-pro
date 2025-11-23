# LINE Opener Pro - 完整流程測試腳本
# 測試從清除環境到安裝完成的完整流程

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LINE Opener Pro - 完整流程測試" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 取得實際的 Extension ID
Write-Host "[0/6] 請輸入你的 Extension ID" -ForegroundColor Yellow
Write-Host "      (在 chrome://extensions/ 頁面複製)" -ForegroundColor Gray
$extId = Read-Host "Extension ID"

if ([string]::IsNullOrWhiteSpace($extId)) {
    Write-Host "❌ 未輸入 Extension ID，使用預設值" -ForegroundColor Red
    $extId = "phmpiijeidboekpokjaannamejbkjock"
}

Write-Host "✓ Extension ID: $extId" -ForegroundColor Green
Write-Host ""

# 步驟 1：清除環境
Write-Host "[1/6] 清除現有安裝..." -ForegroundColor Yellow
$installDir = "$env:LOCALAPPDATA\LineOpenerPro"

if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ 已刪除安裝目錄" -ForegroundColor Green
} else {
    Write-Host "  ✓ 安裝目錄不存在" -ForegroundColor Green
}

reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /f 2>$null
Write-Host "  ✓ 已清除註冊表" -ForegroundColor Green
Write-Host ""

# 步驟 2：模擬安裝
Write-Host "[2/6] 執行安裝..." -ForegroundColor Yellow

# 建立安裝目錄
$nativeHostDir = "$installDir\native-host"
New-Item -ItemType Directory -Path $nativeHostDir -Force | Out-Null
Write-Host "  ✓ 已建立目錄: $nativeHostDir" -ForegroundColor Green

# 複製本地檔案（模擬下載）
$sourceDir = "C:\Jim_Data\code\Chrome_extention\line-pro\native-host"
$files = @("line_opener_host.bat", "line_opener_host.ps1", "auto_click_line.ps1")

foreach ($file in $files) {
    Copy-Item "$sourceDir\$file" "$nativeHostDir\$file" -Force
    Write-Host "  ✓ 已複製 $file" -ForegroundColor Green
}

# 建立 manifest
$hostPath = "$nativeHostDir\line_opener_host.bat" -replace '\\', '\\'
$manifest = @"
{
  "name": "com.line.opener",
  "description": "LINE Opener Native Host",
  "path": "$hostPath",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$extId/"
  ]
}
"@

Set-Content "$nativeHostDir\com.line.opener.json" -Value $manifest -Encoding UTF8
Write-Host "  ✓ 已建立 manifest" -ForegroundColor Green

# 註冊到 Chrome
reg add "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /ve /t REG_SZ /d "$nativeHostDir\com.line.opener.json" /f | Out-Null
Write-Host "  ✓ 已註冊到 Chrome" -ForegroundColor Green
Write-Host ""

# 步驟 3：驗證安裝
Write-Host "[3/6] 驗證安裝..." -ForegroundColor Yellow

$checks = @(
    @{
        Name = "批次檔存在"
        Test = { Test-Path "$nativeHostDir\line_opener_host.bat" }
    },
    @{
        Name = "PowerShell 腳本存在"
        Test = { Test-Path "$nativeHostDir\line_opener_host.ps1" }
    },
    @{
        Name = "自動點擊腳本存在"
        Test = { Test-Path "$nativeHostDir\auto_click_line.ps1" }
    },
    @{
        Name = "Manifest 存在"
        Test = { Test-Path "$nativeHostDir\com.line.opener.json" }
    },
    @{
        Name = "註冊表已設定"
        Test = { 
            $result = reg query "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" 2>$null
            return $LASTEXITCODE -eq 0
        }
    }
)

$allPassed = $true
foreach ($check in $checks) {
    $result = & $check.Test
    if ($result) {
        Write-Host "  ✓ $($check.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($check.Name)" -ForegroundColor Red
        $allPassed = $false
    }
}

if (-not $allPassed) {
    Write-Host ""
    Write-Host "❌ 驗證失敗，請檢查錯誤" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 步驟 4：檢查 Manifest 內容
Write-Host "[4/6] 檢查 Manifest 內容..." -ForegroundColor Yellow
$manifestContent = Get-Content "$nativeHostDir\com.line.opener.json" -Raw | ConvertFrom-Json

Write-Host "  Name: $($manifestContent.name)" -ForegroundColor Gray
Write-Host "  Path: $($manifestContent.path)" -ForegroundColor Gray
Write-Host "  Extension ID: $($manifestContent.allowed_origins[0])" -ForegroundColor Gray

if ($manifestContent.allowed_origins[0] -like "*$extId*") {
    Write-Host "  ✓ Extension ID 匹配" -ForegroundColor Green
} else {
    Write-Host "  ✗ Extension ID 不匹配" -ForegroundColor Red
    Write-Host "    預期: chrome-extension://$extId/" -ForegroundColor Yellow
    Write-Host "    實際: $($manifestContent.allowed_origins[0])" -ForegroundColor Yellow
}

Write-Host ""

# 步驟 5：測試 Native Host 通訊
Write-Host "[5/6] 測試 Native Host 通訊..." -ForegroundColor Yellow
Write-Host "  ⚠️  此步驟需要 Chrome 擴充程式配合" -ForegroundColor Yellow
Write-Host "  請在 Chrome 中：" -ForegroundColor Gray
Write-Host "    1. 前往 chrome://extensions/" -ForegroundColor Gray
Write-Host "    2. 重新載入「Open LINE in Edge (Pro)」" -ForegroundColor Gray
Write-Host "    3. 點擊擴充圖示" -ForegroundColor Gray
Write-Host "    4. 點擊「重新檢測」按鈕" -ForegroundColor Gray
Write-Host ""

# 步驟 6：開啟測試頁面
Write-Host "[6/6] 開啟測試頁面..." -ForegroundColor Yellow
$testPage = "C:\Jim_Data\code\Chrome_extention\line-pro\docs\install-test.html"

if (Test-Path $testPage) {
    Start-Process $testPage
    Write-Host "  ✓ 已開啟測試頁面" -ForegroundColor Green
} else {
    Write-Host "  ✗ 測試頁面不存在: $testPage" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  測試準備完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "1. 在 Chrome 重新載入擴充程式" -ForegroundColor White
Write-Host "2. 點擊擴充圖示" -ForegroundColor White
Write-Host "3. 點擊「重新檢測」按鈕" -ForegroundColor White
Write-Host "4. 應該會看到「正在開啟 LINE...」" -ForegroundColor White
Write-Host "5. Edge 自動開啟並點擊 LINE" -ForegroundColor White
Write-Host ""
Write-Host "如果成功，測試完成！✅" -ForegroundColor Green
Write-Host ""

# 等待用戶確認
Read-Host "按 Enter 結束測試腳本"
