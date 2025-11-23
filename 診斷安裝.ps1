# Native Host 安裝診斷腳本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Native Host 安裝診斷" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$installDir = "$env:LOCALAPPDATA\LineOpenerPro\native-host"

# 1. 檢查安裝目錄
Write-Host "[1] 檢查安裝目錄..." -ForegroundColor Yellow
if (Test-Path $installDir) {
    Write-Host "  [OK] 目錄存在: $installDir" -ForegroundColor Green
    
    $files = @("line_opener_host.bat", "line_opener_host.ps1", "auto_click_line.ps1", "com.line.opener.json")
    foreach ($file in $files) {
        $filePath = Join-Path $installDir $file
        if (Test-Path $filePath) {
            $size = (Get-Item $filePath).Length
            Write-Host "  [OK] $file ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $file 不存在" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  [FAIL] 目錄不存在" -ForegroundColor Red
}

Write-Host ""

# 2. 檢查 Registry
Write-Host "[2] 檢查 Registry..." -ForegroundColor Yellow
$regPath = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.line.opener"
if (Test-Path $regPath) {
    $value = (Get-ItemProperty $regPath).'(default)'
    Write-Host "  [OK] Registry 存在" -ForegroundColor Green
    Write-Host "  路徑: $value" -ForegroundColor Gray
    
    if (Test-Path $value) {
        Write-Host "  [OK] Manifest 文件存在" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Manifest 文件不存在" -ForegroundColor Red
    }
} else {
    Write-Host "  [FAIL] Registry 不存在" -ForegroundColor Red
}

Write-Host ""

# 3. 檢查 Manifest 內容
Write-Host "[3] 檢查 Manifest 內容..." -ForegroundColor Yellow
$manifestPath = Join-Path $installDir "com.line.opener.json"
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    Write-Host "  Name: $($manifest.name)" -ForegroundColor Gray
    Write-Host "  Path: $($manifest.path)" -ForegroundColor Gray
    Write-Host "  Allowed Origins: $($manifest.allowed_origins -join ', ')" -ForegroundColor Gray
    
    # 檢查 path 是否存在
    $batPath = $manifest.path -replace '\\\\', '\'
    if (Test-Path $batPath) {
        Write-Host "  [OK] BAT 文件存在" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] BAT 文件不存在: $batPath" -ForegroundColor Red
    }
} else {
    Write-Host "  [FAIL] Manifest 不存在" -ForegroundColor Red
}

Write-Host ""

# 4. 檢查 auto_click_line.ps1 版本
Write-Host "[4] 檢查 auto_click_line.ps1 版本..." -ForegroundColor Yellow
$autoClickPath = Join-Path $installDir "auto_click_line.ps1"
if (Test-Path $autoClickPath) {
    $content = Get-Content $autoClickPath -Raw
    if ($content -match '\$winProcessId') {
        Write-Host "  [OK] 使用新版本 (winProcessId)" -ForegroundColor Green
    } elseif ($content -match '\$processId') {
        Write-Host "  [WARN] 使用舊版本 (processId)" -ForegroundColor Yellow
        Write-Host "  請重新執行安裝指令" -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] 無法判斷版本" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [FAIL] 文件不存在" -ForegroundColor Red
}

Write-Host ""

# 5. 測試 Native Host
Write-Host "[5] 測試 Native Host..." -ForegroundColor Yellow
$batPath = Join-Path $installDir "line_opener_host.bat"
if (Test-Path $batPath) {
    Write-Host "  正在測試..." -ForegroundColor Gray
    
    # 創建測試訊息
    $testMessage = @{ action = "ping" } | ConvertTo-Json -Compress
    $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($testMessage)
    $lengthBytes = [BitConverter]::GetBytes($messageBytes.Length)
    
    # 寫入臨時文件
    $tempInput = [System.IO.Path]::GetTempFileName()
    $tempOutput = [System.IO.Path]::GetTempFileName()
    
    [System.IO.File]::WriteAllBytes($tempInput, $lengthBytes + $messageBytes)
    
    # 執行測試
    $process = Start-Process -FilePath $batPath -RedirectStandardInput $tempInput -RedirectStandardOutput $tempOutput -NoNewWindow -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        $output = Get-Content $tempOutput -Raw -Encoding Byte
        if ($output) {
            Write-Host "  [OK] Native Host 回應正常" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Native Host 無回應" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [FAIL] Native Host 執行失敗 (Exit Code: $($process.ExitCode))" -ForegroundColor Red
    }
    
    Remove-Item $tempInput, $tempOutput -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  [FAIL] BAT 文件不存在" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  診斷完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "如果所有檢查都通過但擴充程式仍然無法連接，請：" -ForegroundColor Yellow
Write-Host "1. 在 chrome://extensions/ 重新載入擴充程式" -ForegroundColor Yellow
Write-Host "2. 重新啟動 Chrome 瀏覽器" -ForegroundColor Yellow
Write-Host "3. 點擊擴充圖示，然後點擊「重新檢測」" -ForegroundColor Yellow
