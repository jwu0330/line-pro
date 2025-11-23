# LINE Opener Pro - 驗證安裝腳本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  驗證 Native Host 安裝狀態" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$installDir = "$env:LOCALAPPDATA\LineOpenerPro\native-host"

# 檢查項目
$checks = @{
    "安裝目錄" = { Test-Path $installDir }
    "line_opener_host.bat" = { Test-Path "$installDir\line_opener_host.bat" }
    "line_opener_host.ps1" = { Test-Path "$installDir\line_opener_host.ps1" }
    "auto_click_line.ps1" = { Test-Path "$installDir\auto_click_line.ps1" }
    "com.line.opener.json" = { Test-Path "$installDir\com.line.opener.json" }
    "Chrome 註冊表" = { 
        $result = reg query "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" 2>$null
        return $LASTEXITCODE -eq 0
    }
}

$allPassed = $true

foreach ($check in $checks.GetEnumerator()) {
    $result = & $check.Value
    if ($result) {
        Write-Host "✓ $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "✗ $($check.Key)" -ForegroundColor Red
        $allPassed = $false
    }
}

Write-Host ""

if (Test-Path "$installDir\com.line.opener.json") {
    Write-Host "Manifest 內容：" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Get-Content "$installDir\com.line.opener.json"
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

if (Test-Path "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.line.opener") {
    Write-Host "註冊表路徑：" -ForegroundColor Yellow
    $regPath = (Get-ItemProperty "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.line.opener").'(default)'
    Write-Host $regPath -ForegroundColor Gray
    Write-Host ""
}

if ($allPassed) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ 所有檢查通過！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ❌ 部分檢查失敗" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
}

Write-Host ""
