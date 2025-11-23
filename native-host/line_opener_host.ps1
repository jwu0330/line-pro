# Native Messaging Host - PowerShell 版本
# 處理來自 Chrome 的訊息並執行 LINE 開啟腳本

# 讀取訊息長度（4 bytes）
$lengthBytes = New-Object byte[] 4
$stdin = [Console]::OpenStandardInput()
$bytesRead = $stdin.Read($lengthBytes, 0, 4)

if ($bytesRead -eq 0) {
    exit 0
}

# 解析訊息長度
$messageLength = [BitConverter]::ToInt32($lengthBytes, 0)

# 讀取訊息內容
$messageBytes = New-Object byte[] $messageLength
$stdin.Read($messageBytes, 0, $messageLength) | Out-Null
$messageJson = [System.Text.Encoding]::UTF8.GetString($messageBytes)

# 解析 JSON
$message = $messageJson | ConvertFrom-Json

# 處理訊息
if ($message.action -eq 'ping') {
    # Ping 命令 - 用於檢測 Native Host 是否安裝
    $response = @{
        success = $true
        message = "Native Host is running"
        version = "2.0.0"
    } | ConvertTo-Json -Compress
} elseif ($message.action -eq 'openLINE') {
    # 執行 LINE 開啟腳本
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $autoClickScript = Join-Path $scriptDir "auto_click_line.ps1"
    
    # 在背景執行
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -NonInteractive -File `"$autoClickScript`"" -WindowStyle Hidden
    
    # 回應成功
    $response = @{
        success = $true
        message = "LINE opener triggered"
    } | ConvertTo-Json -Compress
} else {
    # 回應錯誤
    $response = @{
        success = $false
        error = "Unknown action: $($message.action)"
    } | ConvertTo-Json -Compress
}

# 發送回應
$responseBytes = [System.Text.Encoding]::UTF8.GetBytes($response)
$lengthBytes = [BitConverter]::GetBytes($responseBytes.Length)

$stdout = [Console]::OpenStandardOutput()
$stdout.Write($lengthBytes, 0, 4)
$stdout.Write($responseBytes, 0, $responseBytes.Length)
$stdout.Flush()
