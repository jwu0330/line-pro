# Final auto-click solution
# Step 1: Click Extensions button
# Step 2: Find and click LINE in the menu

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Auto-Click LINE (Final Solution)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load assemblies
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms

# Find Edge
Write-Host "[1/5] Finding Edge..." -ForegroundColor Yellow
$edge = Get-Process msedge -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1

if (-not $edge) {
    Write-Host "      Starting Edge with new tab..." -ForegroundColor Gray
    $edgePath = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgePath)) {
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    }
    # Start Edge with a new tab page (not login page)
    Start-Process $edgePath "edge://newtab/"
    Start-Sleep -Seconds 3
    $edge = Get-Process msedge -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
} else {
    Write-Host "      Edge already running, opening new tab..." -ForegroundColor Gray
    # Open a new tab to ensure extensions are available
    $edgePath = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgePath)) {
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    }
    Start-Process $edgePath "edge://newtab/"
    Start-Sleep -Seconds 2
}

if (-not $edge) {
    Write-Host "      [FAIL] Cannot find Edge" -ForegroundColor Red
    exit 1
}

Write-Host "      [OK] Edge found" -ForegroundColor Green

# Bring to foreground
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public const int SW_RESTORE = 9;
}
"@

[Win]::ShowWindow($edge.MainWindowHandle, [Win]::SW_RESTORE) | Out-Null
[Win]::SetForegroundWindow($edge.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 500

# Get automation element
Write-Host "[2/5] Getting UI automation..." -ForegroundColor Yellow
$element = [System.Windows.Automation.AutomationElement]::FromHandle($edge.MainWindowHandle)

if (-not $element) {
    Write-Host "      [FAIL] Cannot get automation element" -ForegroundColor Red
    exit 1
}

Write-Host "      [OK] UI automation ready" -ForegroundColor Green

# Find Extensions button
Write-Host "[3/5] Finding Extensions button..." -ForegroundColor Yellow

# Wait a bit for the new tab to fully load
Start-Sleep -Milliseconds 1000

# Refresh element to get latest UI state
$element = [System.Windows.Automation.AutomationElement]::FromHandle($edge.MainWindowHandle)

# Try multiple search strategies
$extensionsButton = $null

# Strategy 1: By name (Chinese)
$nameCondition = New-Object System.Windows.Automation.PropertyCondition(
    [System.Windows.Automation.AutomationElement]::NameProperty,
    "擴充功能"
)
$extensionsButton = $element.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $nameCondition)

# Strategy 2: By name (English)
if (-not $extensionsButton) {
    $nameCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty,
        "Extensions"
    )
    $extensionsButton = $element.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $nameCondition)
}

# Strategy 3: By AutomationId
if (-not $extensionsButton) {
    $idCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::AutomationIdProperty,
        "view_1015"
    )
    $extensionsButton = $element.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $idCondition)
}

# Strategy 4: Search all buttons and find by name pattern
if (-not $extensionsButton) {
    Write-Host "      Searching all buttons..." -ForegroundColor Gray
    $buttonCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Button
    )
    $allButtons = $element.FindAll([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
    
    foreach ($btn in $allButtons) {
        $name = $btn.Current.Name
        $automationId = $btn.Current.AutomationId
        if ($name -match "擴充|Extension|extension" -or $automationId -eq "view_1015") {
            Write-Host "      Found: $name (ID: $automationId)" -ForegroundColor Gray
            $extensionsButton = $btn
            break
        }
    }
}

$lineButton = $null

if (-not $extensionsButton) {
    Write-Host "      [FAIL] Extensions button not found" -ForegroundColor Red
    Write-Host "      Trying direct LINE icon search..." -ForegroundColor Yellow
    
    # Try to find LINE button directly (if it's pinned to toolbar)
    $lineCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty,
        "LINE"
    )
    $lineButton = $element.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $lineCondition)
    
    if (-not $lineButton) {
        Write-Host "      [FAIL] LINE button also not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "Debug: Listing all buttons..." -ForegroundColor Yellow
        $buttonCondition = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
            [System.Windows.Automation.ControlType]::Button
        )
        $allButtons = $element.FindAll([System.Windows.Automation.TreeScope]::Descendants, $buttonCondition)
        $count = 0
        foreach ($btn in $allButtons) {
            $name = $btn.Current.Name
            $automationId = $btn.Current.AutomationId
            if ($name -or $automationId) {
                Write-Host "  - '$name' (ID: $automationId)" -ForegroundColor Gray
                $count++
                if ($count -ge 25) { break }
            }
        }
        
        exit 1
    }
    
    Write-Host "      [OK] Found LINE button directly!" -ForegroundColor Green
} else {
    Write-Host "      [OK] Extensions button found" -ForegroundColor Green
    
    # Click Extensions button using UI Automation (no mouse needed)
    Write-Host "[4/5] Opening Extensions menu..." -ForegroundColor Yellow
    
    $clicked = $false
    
    # Try InvokePattern first (standard button click)
    try {
        $invokePattern = $extensionsButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        if ($invokePattern) {
            $invokePattern.Invoke()
            Write-Host "      [OK] Extensions menu opened (Invoke)" -ForegroundColor Green
            $clicked = $true
        }
    } catch {
        Write-Host "      InvokePattern not available" -ForegroundColor Gray
    }
    
    # Try TogglePattern (for toggle buttons)
    if (-not $clicked) {
        try {
            $togglePattern = $extensionsButton.GetCurrentPattern([System.Windows.Automation.TogglePattern]::Pattern)
            if ($togglePattern) {
                $togglePattern.Toggle()
                Write-Host "      [OK] Extensions menu opened (Toggle)" -ForegroundColor Green
                $clicked = $true
            }
        } catch {
            Write-Host "      TogglePattern not available" -ForegroundColor Gray
        }
    }
    
    # Try ExpandCollapsePattern (for expandable buttons)
    if (-not $clicked) {
        try {
            $expandPattern = $extensionsButton.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
            if ($expandPattern) {
                $expandPattern.Expand()
                Write-Host "      [OK] Extensions menu opened (Expand)" -ForegroundColor Green
                $clicked = $true
            }
        } catch {
            Write-Host "      ExpandCollapsePattern not available" -ForegroundColor Gray
        }
    }
    
    # Last resort: Use SendKeys to simulate Enter key
    if (-not $clicked) {
        Write-Host "      Using keyboard simulation..." -ForegroundColor Yellow
        Add-Type -AssemblyName System.Windows.Forms
        
        # Set focus to the button
        try {
            $extensionsButton.SetFocus()
            Start-Sleep -Milliseconds 100
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
            Write-Host "      [OK] Extensions menu opened (Keyboard)" -ForegroundColor Green
            $clicked = $true
        } catch {
            Write-Host "      [FAIL] Cannot invoke Extensions button" -ForegroundColor Red
            Write-Host "      Error: $_" -ForegroundColor Gray
            exit 1
        }
    }
    
    Start-Sleep -Milliseconds 800
    
    # Find LINE in the menu
    Write-Host "[5/5] Finding LINE in menu..." -ForegroundColor Yellow
    
    # Refresh automation element to get the menu
    $element = [System.Windows.Automation.AutomationElement]::FromHandle($edge.MainWindowHandle)
    
    $lineCondition = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::NameProperty,
        "LINE"
    )
    
    $lineButton = $element.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $lineCondition)
    
    if (-not $lineButton) {
        Write-Host "      [FAIL] LINE not found in menu" -ForegroundColor Red
        Write-Host "      LINE extension might not be installed or enabled" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "      [OK] LINE found!" -ForegroundColor Green
}

# Click LINE using UI Automation (no mouse needed)
Write-Host ""
Write-Host "[*] Clicking LINE..." -ForegroundColor Yellow

$success = $false

# Try InvokePattern first (standard button click)
try {
    $invokePattern = $lineButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    if ($invokePattern) {
        $invokePattern.Invoke()
        Write-Host "    [OK] LINE clicked (Invoke)!" -ForegroundColor Green
        $success = $true
    }
} catch {
    Write-Host "    InvokePattern not available" -ForegroundColor Gray
}

# Try TogglePattern
if (-not $success) {
    try {
        $togglePattern = $lineButton.GetCurrentPattern([System.Windows.Automation.TogglePattern]::Pattern)
        if ($togglePattern) {
            $togglePattern.Toggle()
            Write-Host "    [OK] LINE clicked (Toggle)!" -ForegroundColor Green
            $success = $true
        }
    } catch {
        Write-Host "    TogglePattern not available" -ForegroundColor Gray
    }
}

# Try ExpandCollapsePattern
if (-not $success) {
    try {
        $expandPattern = $lineButton.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern)
        if ($expandPattern) {
            $expandPattern.Expand()
            Write-Host "    [OK] LINE clicked (Expand)!" -ForegroundColor Green
            $success = $true
        }
    } catch {
        Write-Host "    ExpandCollapsePattern not available" -ForegroundColor Gray
    }
}

# Last resort: Use SendKeys
if (-not $success) {
    Write-Host "    Using keyboard simulation..." -ForegroundColor Yellow
    try {
        $lineButton.SetFocus()
        Start-Sleep -Milliseconds 100
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Write-Host "    [OK] LINE clicked (Keyboard)!" -ForegroundColor Green
        $success = $true
    } catch {
        Write-Host "    [FAIL] Cannot invoke LINE button" -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor Gray
        $success = $false
    }
}

if ($success) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "LINE is opening, closing original Edge window..." -ForegroundColor Cyan
    
    # 立即關閉原本的 Edge 視窗（不等待）
    try {
        Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using System.Text;
        public class WindowHelper {
            [DllImport("user32.dll")]
            public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
            [DllImport("user32.dll")]
            public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
            [DllImport("user32.dll")]
            public static extern bool IsWindowVisible(IntPtr hWnd);
            [DllImport("user32.dll")]
            public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
            [DllImport("user32.dll")]
            public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
            public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
            public const uint WM_CLOSE = 0x0010;
        }
"@
        
        # 找到所有 Edge 視窗（排除 LINE）
        $edgeWindows = New-Object System.Collections.ArrayList
        $callback = {
            param($hwnd, $lParam)
            if ([WindowHelper]::IsWindowVisible($hwnd)) {
                $winProcessId = 0
                [WindowHelper]::GetWindowThreadProcessId($hwnd, [ref]$winProcessId) | Out-Null
                
                if ($winProcessId -eq $edge.Id) {
                    $title = New-Object System.Text.StringBuilder 256
                    [WindowHelper]::GetWindowText($hwnd, $title, 256) | Out-Null
                    $titleStr = $title.ToString()
                    
                    # 排除 LINE 視窗
                    if ($titleStr -notmatch "LINE") {
                        $edgeWindows.Add(@{Handle=$hwnd; Title=$titleStr}) | Out-Null
                    }
                }
            }
            return $true
        }
        
        [WindowHelper]::EnumWindows($callback, [IntPtr]::Zero)
        
        # 立即關閉所有非 LINE 的 Edge 視窗
        foreach ($window in $edgeWindows) {
            [WindowHelper]::PostMessage($window.Handle, [WindowHelper]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
        }
        
        Write-Host "Original Edge windows closed" -ForegroundColor Green
    } catch {
        Write-Host "Error: $_" -ForegroundColor Yellow
    }
    
    exit 0
}

exit 1
