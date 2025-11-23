# LINE Opener Pro - 快速測試腳本
# 使用預設 Extension ID 快速測試

$extId = "phmpiijeidboekpokjaannamejbkjock"

Write-Host "🚀 快速測試 - Extension ID: $extId" -ForegroundColor Cyan
Write-Host ""

# 清除並重新安裝
Write-Host "清除舊安裝..." -ForegroundColor Yellow
$installDir = "$env:LOCALAPPDATA\LineOpenerPro"
Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /f 2>$null

Write-Host "執行安裝..." -ForegroundColor Yellow
$nativeHostDir = "$installDir\native-host"
New-Item -ItemType Directory -Path $nativeHostDir -Force | Out-Null

# 複製檔案
$sourceDir = "C:\Jim_Data\code\Chrome_extention\line-pro\native-host"
Copy-Item "$sourceDir\*" "$nativeHostDir\" -Force

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

# 註冊
reg add "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /ve /t REG_SZ /d "$nativeHostDir\com.line.opener.json" /f | Out-Null

Write-Host ""
Write-Host "✅ 安裝完成！" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "1. 在 Chrome 重新載入擴充程式" -ForegroundColor White
Write-Host "2. 點擊擴充圖示 → 點擊「重新檢測」" -ForegroundColor White
Write-Host ""
