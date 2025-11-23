# 使用 .NET 生成簡單的 LINE 圖示
Add-Type -AssemblyName System.Drawing

$lineGreen = [System.Drawing.Color]::FromArgb(0, 185, 0)
$white = [System.Drawing.Color]::White

function Create-Icon {
    param($size, $filename)
    
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # 抗鋸齒
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    # 綠色背景
    $brush = New-Object System.Drawing.SolidBrush($lineGreen)
    $graphics.FillRectangle($brush, 0, 0, $size, $size)
    
    # 白色 "L" 字母
    $font = New-Object System.Drawing.Font("Arial", ($size * 0.5), [System.Drawing.FontStyle]::Bold)
    $whiteBrush = New-Object System.Drawing.SolidBrush($white)
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $rect = New-Object System.Drawing.RectangleF(0, 0, $size, $size)
    $graphics.DrawString("L", $font, $whiteBrush, $rect, $format)
    
    # 儲存
    $bitmap.Save($filename, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # 清理
    $graphics.Dispose()
    $bitmap.Dispose()
    $brush.Dispose()
    $whiteBrush.Dispose()
    $font.Dispose()
    
    Write-Host "已生成: $filename"
}

# 生成三個尺寸的圖示
$iconsPath = Join-Path $PSScriptRoot "icons"
Create-Icon 16 (Join-Path $iconsPath "icon16.png")
Create-Icon 48 (Join-Path $iconsPath "icon48.png")
Create-Icon 128 (Join-Path $iconsPath "icon128.png")

Write-Host "All icons generated successfully!" -ForegroundColor Green
