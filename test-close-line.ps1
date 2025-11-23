# 測試腳本：找到並關閉 LINE 視窗
# 這個腳本會幫助我們確認能否正確找到 LINE 視窗並點擊關閉按鈕

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  測試關閉 LINE 視窗" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

# 尋找 LINE 視窗
Write-Host "[1] 尋找 LINE 視窗..." -ForegroundColor Yellow

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class WindowFinder {
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    [DllImport("user32.dll")]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

$lineWindow = $null
$callback = {
    param($hwnd, $lParam)
    if ([WindowFinder]::IsWindowVisible($hwnd)) {
        $title = New-Object System.Text.StringBuilder 256
        [WindowFinder]::GetWindowText($hwnd, $title, 256) | Out-Null
        $titleStr = $title.ToString()
        if ($titleStr -match "LINE") {
            Write-Host "    找到視窗: $titleStr" -ForegroundColor Green
            Write-Host "    視窗控制代碼: $hwnd" -ForegroundColor Gray
            $script:lineWindow = $hwnd
            return $false
        }
    }
    return $true
}

[WindowFinder]::EnumWindows($callback, [IntPtr]::Zero)

if (-not $lineWindow) {
    Write-Host "    [FAIL] 找不到 LINE 視窗" -ForegroundColor Red
    Write-Host "    請先開啟 LINE 視窗再執行此腳本" -ForegroundColor Yellow
    exit 1
}

# 取得視窗位置和大小
Write-Host ""
Write-Host "[2] 取得視窗資訊..." -ForegroundColor Yellow

$rect = New-Object WindowFinder+RECT
[WindowFinder]::GetWindowRect($lineWindow, [ref]$rect) | Out-Null

Write-Host "    Left: $($rect.Left)" -ForegroundColor Gray
Write-Host "    Top: $($rect.Top)" -ForegroundColor Gray
Write-Host "    Right: $($rect.Right)" -ForegroundColor Gray
Write-Host "    Bottom: $($rect.Bottom)" -ForegroundColor Gray
Write-Host "    Width: $($rect.Right - $rect.Left)" -ForegroundColor Gray
Write-Host "    Height: $($rect.Bottom - $rect.Top)" -ForegroundColor Gray

# 計算關閉按鈕位置
Write-Host ""
Write-Host "[3] 計算關閉按鈕位置..." -ForegroundColor Yellow

# 嘗試不同的偏移量
$offsets = @(
    @{X=15; Y=15; Name="預設 (15, 15)"},
    @{X=20; Y=15; Name="稍微往左 (20, 15)"},
    @{X=25; Y=15; Name="更往左 (25, 15)"},
    @{X=15; Y=20; Name="稍微往下 (15, 20)"},
    @{X=20; Y=20; Name="往左下 (20, 20)"}
)

Write-Host "    可能的關閉按鈕位置：" -ForegroundColor Cyan
foreach ($offset in $offsets) {
    $closeX = $rect.Right - $offset.X
    $closeY = $rect.Top + $offset.Y
    Write-Host "      $($offset.Name): ($closeX, $closeY)" -ForegroundColor Gray
}

# 將視窗置於前景
Write-Host ""
Write-Host "[4] 將 LINE 視窗置於前景..." -ForegroundColor Yellow
[WindowFinder]::SetForegroundWindow($lineWindow) | Out-Null
Start-Sleep -Milliseconds 500
Write-Host "    完成" -ForegroundColor Green

# 使用 UI Automation 嘗試找到關閉按鈕
Write-Host ""
Write-Host "[5] 使用 UI Automation 尋找關閉按鈕..." -ForegroundColor Yellow

try {
    $lineElement = [System.Windows.Automation.AutomationElement]::FromHandle($lineWindow)
    
    if ($lineElement) {
        Write-Host "    成功取得 AutomationElement" -ForegroundColor Green
        
        # 取得邊界矩形
        $uiRect = $lineElement.Current.BoundingRectangle
        Write-Host "    UI Automation 矩形:" -ForegroundColor Gray
        Write-Host "      Left: $($uiRect.Left)" -ForegroundColor Gray
        Write-Host "      Top: $($uiRect.Top)" -ForegroundColor Gray
        Write-Host "      Right: $($uiRect.Right)" -ForegroundColor Gray
        Write-Host "      Bottom: $($uiRect.Bottom)" -ForegroundColor Gray
        
        # 嘗試找到關閉按鈕
        $buttonCondition = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::Button
        )
        
        $buttons = $lineElement.FindAll([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
        
        Write-Host ""
        Write-Host "    找到 $($buttons.Count) 個按鈕" -ForegroundColor Cyan
        
        $closeButton = $null
        foreach ($button in $buttons) {
            $name = $button.Current.Name
            $automationId = $button.Current.AutomationId
            $buttonRect = $button.Current.BoundingRectangle
            
            # 檢查是否在右上角
            $isTopRight = ($buttonRect.Right -ge ($uiRect.Right - 50)) -and ($buttonRect.Top -le ($uiRect.Top + 50))
            
            if ($isTopRight) {
                Write-Host "      可能的關閉按鈕: '$name' (ID: $automationId)" -ForegroundColor Yellow
                Write-Host "        位置: ($($buttonRect.Left), $($buttonRect.Top))" -ForegroundColor Gray
                
                if (-not $closeButton) {
                    $closeButton = $button
                }
            }
        }
        
        if ($closeButton) {
            Write-Host ""
            Write-Host "    找到關閉按鈕！" -ForegroundColor Green
            Write-Host "    是否要點擊關閉？(Y/N)" -ForegroundColor Yellow
            $response = Read-Host
            
            if ($response -eq 'Y' -or $response -eq 'y') {
                try {
                    $invokePattern = $closeButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                    $invokePattern.Invoke()
                    Write-Host "    已點擊關閉按鈕" -ForegroundColor Green
                } catch {
                    Write-Host "    無法使用 InvokePattern，嘗試滑鼠點擊..." -ForegroundColor Yellow
                    
                    $btnRect = $closeButton.Current.BoundingRectangle
                    $clickX = $btnRect.Left + ($btnRect.Width / 2)
                    $clickY = $btnRect.Top + ($btnRect.Height / 2)
                    
                    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($clickX, $clickY)
                    Start-Sleep -Milliseconds 200
                    
                    Add-Type @"
                    using System;
                    using System.Runtime.InteropServices;
                    public class MouseClick {
                        [DllImport("user32.dll")]
                        public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
                        public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
                        public const uint MOUSEEVENTF_LEFTUP = 0x0004;
                    }
"@
                    [MouseClick]::mouse_event([MouseClick]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                    Start-Sleep -Milliseconds 50
                    [MouseClick]::mouse_event([MouseClick]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
                    
                    Write-Host "    已模擬滑鼠點擊" -ForegroundColor Green
                }
            }
        } else {
            Write-Host ""
            Write-Host "    找不到明確的關閉按鈕" -ForegroundColor Yellow
            Write-Host "    嘗試使用預設位置..." -ForegroundColor Yellow
            
            $closeX = $uiRect.Right - 15
            $closeY = $uiRect.Top + 15
            
            Write-Host "    移動滑鼠到 ($closeX, $closeY)" -ForegroundColor Gray
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($closeX, $closeY)
            
            Write-Host "    是否要在此位置點擊？(Y/N)" -ForegroundColor Yellow
            $response = Read-Host
            
            if ($response -eq 'Y' -or $response -eq 'y') {
                Add-Type @"
                using System;
                using System.Runtime.InteropServices;
                public class MouseClick2 {
                    [DllImport("user32.dll")]
                    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
                    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
                    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
                }
"@
                [MouseClick2]::mouse_event([MouseClick2]::MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                Start-Sleep -Milliseconds 50
                [MouseClick2]::mouse_event([MouseClick2]::MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
                
                Write-Host "    已點擊" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "    [ERROR] $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  測試完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
