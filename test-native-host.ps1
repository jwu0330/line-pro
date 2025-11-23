# 測試 Native Host 安裝狀態
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Native Host 診斷工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 檢查安裝目錄
$installDir = "$env:LOCALAPPDATA\LineOpenerPro\native-host"
Write-Host "[1] 檢查安裝目錄..." -ForegroundColor Yellow
if (Test-Path $installDir) {
    Write-Host "    ✓ 目錄存在: $installDir" -ForegroundColor Green
    
    # 列出檔案
    $files = Get-ChildItem $installDir
    Write-Host "    檔案列表:" -ForegroundColor Gray
    foreach ($file in $files) {
        Write-Host "      - $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "    ✗ 目錄不存在" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 2. 檢查 manifest 檔案
Write-Host "[2] 檢查 manifest 檔案..." -ForegroundColor Yellow
$manifestPath = "$installDir\com.line.opener.json"
if (Test-Path $manifestPath) {
    Write-Host "    ✓ manifest 檔案存在" -ForegroundColor Green
    $manifest = Get-Content $manifestPath -Raw
    Write-Host "    內容:" -ForegroundColor Gray
    Write-Host $manifest -ForegroundColor Gray
} else {
    Write-Host "    ✗ manifest 檔案不存在" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 3. 檢查註冊表
Write-Host "[3] 檢查註冊表..." -ForegroundColor Yellow
try {
    $regPath = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.line.opener"
    $regValue = Get-ItemProperty -Path $regPath -Name "(default)" -ErrorAction Stop
    Write-Host "    ✓ 註冊表項目存在" -ForegroundColor Green
    Write-Host "    路徑: $($regValue.'(default)')" -ForegroundColor Gray
} catch {
    Write-Host "    ✗ 註冊表項目不存在" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 4. 測試 Native Host
Write-Host "[4] 測試 Native Host..." -ForegroundColor Yellow
$hostBat = "$installDir\line_opener_host.bat"
if (Test-Path $hostBat) {
    Write-Host "    ✓ line_opener_host.bat 存在" -ForegroundColor Green
    
    # 測試執行（發送 ping）
    Write-Host "    測試 ping 訊息..." -ForegroundColor Gray
    $pingMessage = '{"action":"ping"}'
    $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($pingMessage)
    $lengthBytes = [BitConverter]::GetBytes($messageBytes.Length)
    
    # 創建臨時輸入檔案
    $tempInput = [System.IO.Path]::GetTempFileName()
    $tempOutput = [System.IO.Path]::GetTempFileName()
    
    [System.IO.File]::WriteAllBytes($tempInput, $lengthBytes + $messageBytes)
    
    # 執行 Native Host
    $process = Start-Process -FilePath $hostBat -RedirectStandardInput $tempInput -RedirectStandardOutput $tempOutput -NoNewWindow -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "    ✓ Native Host 執行成功" -ForegroundColor Green
        $output = Get-Content $tempOutput -Raw -Encoding Byte
        if ($output) {
            Write-Host "    回應: $([System.Text.Encoding]::UTF8.GetString($output[4..($output.Length-1)]))" -ForegroundColor Gray
        }
    } else {
        Write-Host "    ✗ Native Host 執行失敗 (Exit Code: $($process.ExitCode))" -ForegroundColor Red
    }
    
    # 清理
    Remove-Item $tempInput -Force
    Remove-Item $tempOutput -Force
} else {
    Write-Host "    ✗ line_opener_host.bat 不存在" -ForegroundColor Red
}
Write-Host ""

# 5. 檢查 Extension ID
Write-Host "[5] 檢查 Extension ID..." -ForegroundColor Yellow
$manifestJson = $manifest | ConvertFrom-Json
$allowedOrigin = $manifestJson.allowed_origins[0]
if ($allowedOrigin -match "chrome-extension://([^/]+)/") {
    $extId = $matches[1]
    Write-Host "    Extension ID: $extId" -ForegroundColor Cyan
    Write-Host "    請確認這個 ID 與 Chrome 擴充程式的 ID 相同" -ForegroundColor Yellow
} else {
    Write-Host "    ✗ 無法解析 Extension ID" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  診斷完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "如果所有檢查都通過，但 Chrome 仍顯示未安裝：" -ForegroundColor Yellow
Write-Host "1. 完全關閉所有 Chrome 視窗" -ForegroundColor White
Write-Host "2. 重新開啟 Chrome" -ForegroundColor White
Write-Host "3. 前往 chrome://extensions/" -ForegroundColor White
Write-Host "4. 找到擴充程式並點擊「重新載入」" -ForegroundColor White
Write-Host "5. 點擊擴充圖示測試" -ForegroundColor White
Write-Host ""
