# 註冊自訂協定 "openline://" 到 Windows
# 這樣 Chrome 就可以呼叫它來啟動 Edge

$protocolName = "openline"
$batPath = Join-Path $PSScriptRoot "open_line_in_edge.bat"

# 建立註冊表項目
$regPath = "HKCU:\Software\Classes\$protocolName"

# 建立主鍵
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(Default)" -Value "URL:Open LINE in Edge Protocol"
Set-ItemProperty -Path $regPath -Name "URL Protocol" -Value ""

# 建立 shell\open\command
$commandPath = "$regPath\shell\open\command"
New-Item -Path $commandPath -Force | Out-Null
Set-ItemProperty -Path $commandPath -Name "(Default)" -Value "`"$batPath`""

Write-Host "Protocol registered successfully!" -ForegroundColor Green
Write-Host "You can now use: openline:// in Chrome" -ForegroundColor Cyan
