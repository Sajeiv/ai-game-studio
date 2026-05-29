#Requires -Version 5.1
<#
.SYNOPSIS
    Automated self-check orchestrator for AI-generated Godot 4 games.

.PARAMETER ProjectPath
    Absolute path to the Godot project folder (contains project.godot).

.PARAMETER GameName
    Matches project.godot config/name — used as the window title and log folder name.

.PARAMETER Playthrough
    Array of step hashtables that drive the automated playthrough:
      @{ type="hold";       key="down";  duration_ms=2000 }  # hold key for N ms
      @{ type="press";      key="e"                       }  # tap key once
      @{ type="wait";       duration_ms=1000              }  # pause
      @{ type="screenshot"; label="description"           }  # capture + save

    Supported key names: up, down, left, right, e, space, enter, escape

.PARAMETER ScreenshotDir
    Folder where screenshots are saved. Default: $ProjectPath\tools\screenshots

.OUTPUTS
    JSON report to stdout. Exit code 0 = all phases passed. Exit code 1 = failure.

.EXAMPLE
    # Run from a game-specific wrapper:
    & "$RepoRoot\tools\self_check.ps1" `
        -ProjectPath "C:\...\games\my-game" `
        -GameName "My Game" `
        -Playthrough $steps
#>
param(
    [Parameter(Mandatory)] [string] $ProjectPath,
    [Parameter(Mandatory)] [string] $GameName,
    [Parameter(Mandatory)] [array]  $Playthrough,
    [string] $ScreenshotDir = "",
    [string] $InteractTriggerPath = "",
    [string] $ScreenshotTriggerPath = "",
    [string] $MovementTriggerPath = ""
)

$ErrorActionPreference = "Stop"

# --- Virtual key codes (Win32) ---
$VK = @{
    "up"     = 0x26
    "down"   = 0x28
    "left"   = 0x25
    "right"  = 0x27
    "e"      = 0x45
    "space"  = 0x20
    "enter"  = 0x0D
    "escape" = 0x1B
}

# --- Win32 types (compiled once) ---
Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class Win32 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmd);

    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, int Msg, int wParam, uint lParam);

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessageW(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

    public const uint KEYEVENTF_KEYUP = 0x0002;

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    public static readonly IntPtr HWND_TOPMOST   = new IntPtr(-1);
    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    public const uint SWP_NOMOVE     = 0x0002;
    public const uint SWP_NOSIZE     = 0x0001;
    public const uint SWP_NOACTIVATE = 0x0010;

    [DllImport("user32.dll")]
    public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);

    [DllImport("kernel32.dll")]
    public static extern int GetCurrentThreadId();

    [DllImport("user32.dll")]
    public static extern bool AttachThreadInput(int idAttach, int idAttachTo, bool fAttach);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    public const int SW_RESTORE = 9;
    public const int WM_KEYDOWN = 0x0100;
    public const int WM_KEYUP   = 0x0101;

    private static bool IsExtended(int vk) {
        return vk == 0x25 || vk == 0x26 || vk == 0x27 || vk == 0x28;
    }

    private static void FocusWindow(IntPtr hwnd) {
        int dummy; int tid = GetWindowThreadProcessId(hwnd, out dummy);
        int me = GetCurrentThreadId();
        ShowWindow(hwnd, SW_RESTORE);
        AttachThreadInput(me, tid, true);
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(80);
        AttachThreadInput(me, tid, false);
    }

    public static void HoldKeyBackground(long hwndLong, int vk, int durationMs) {
        var hwnd = new IntPtr(hwndLong);
        // Give Godot focus so it processes the key; key-state reset happens BEFORE the press.
        int dummy; int tid = GetWindowThreadProcessId(hwnd, out dummy);
        int me = GetCurrentThreadId();
        ShowWindow(hwnd, SW_RESTORE);
        AttachThreadInput(me, tid, true);
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(80);
        AttachThreadInput(me, tid, false);
        uint lp_dn = 0x00000001u | (IsExtended(vk) ? 0x01000000u : 0u);
        uint lp_up = 0xC0000001u | (IsExtended(vk) ? 0x01000000u : 0u);
        PostMessage(hwnd, WM_KEYDOWN, vk, lp_dn);
        System.Threading.Thread.Sleep(durationMs);
        PostMessage(hwnd, WM_KEYUP, vk, lp_up);
    }

    public static void PressKeyFocused(long hwndLong, int vk) {
        var hwnd = new IntPtr(hwndLong);
        int dummy; int tid = GetWindowThreadProcessId(hwnd, out dummy);
        int me = GetCurrentThreadId();
        ShowWindow(hwnd, SW_RESTORE);
        AttachThreadInput(me, tid, true);
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(100);
        uint lp_dn = 0x00000001u | (IsExtended(vk) ? 0x01000000u : 0u);
        uint lp_up = 0xC0000001u | (IsExtended(vk) ? 0x01000000u : 0u);
        // SendMessage is synchronous: WndProc processes inline → state set before physics
        SendMessageW(hwnd, WM_KEYDOWN, new IntPtr(vk), new IntPtr((long)lp_dn));
        System.Threading.Thread.Sleep(80);
        SendMessageW(hwnd, WM_KEYUP, new IntPtr(vk), new IntPtr((long)lp_up));
        System.Threading.Thread.Sleep(120);
        AttachThreadInput(me, tid, false);
    }

    public static IntPtr FindWindowStartsWith(string prefix) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((hwnd, lp) => {
            if (!IsWindowVisible(hwnd)) return true;
            var sb = new System.Text.StringBuilder(256);
            GetWindowText(hwnd, sb, 256);
            if (sb.ToString().StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) {
                found = hwnd;
                return false;
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }


    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateCompatibleDC(IntPtr hdc);

    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int nWidth, int nHeight);

    [DllImport("gdi32.dll")]
    public static extern IntPtr SelectObject(IntPtr hdc, IntPtr hgdiobj);

    [DllImport("gdi32.dll")]
    public static extern bool DeleteDC(IntPtr hdc);

    [DllImport("gdi32.dll")]
    public static extern bool DeleteObject(IntPtr hObject);

    [DllImport("user32.dll")]
    public static extern IntPtr GetDC(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);

    [DllImport("gdi32.dll")]
    public static extern bool BitBlt(IntPtr hdcDest, int xDest, int yDest, int w, int h,
                                     IntPtr hdcSrc, int xSrc, int ySrc, int rop);

    public const int SRCCOPY = 0x00CC0020;

    public static bool CaptureWindow(long hwndLong, string path) {
        var hwnd = new IntPtr(hwndLong);
        RECT r;
        if (!GetWindowRect(hwnd, out r)) return false;
        int w = r.Right - r.Left, h = r.Bottom - r.Top;
        if (w <= 0 || h <= 0) return false;
        // Brief AttachThread to legitimize SetForegroundWindow, then detach immediately
        // so Godot gets focus and renders freely (not blocked by our thread).
        int dummy; int tid = GetWindowThreadProcessId(hwnd, out dummy);
        int me = GetCurrentThreadId();
        ShowWindow(hwnd, SW_RESTORE);
        AttachThreadInput(me, tid, true);
        SetForegroundWindow(hwnd);
        AttachThreadInput(me, tid, false);
        // Godot has focus, pin it topmost so nothing covers it during the wait
        SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        System.Threading.Thread.Sleep(600);
        IntPtr screenDC  = GetDC(IntPtr.Zero);
        IntPtr memDC     = CreateCompatibleDC(screenDC);
        IntPtr hBitmap   = CreateCompatibleBitmap(screenDC, w, h);
        IntPtr oldBitmap = SelectObject(memDC, hBitmap);
        bool ok = BitBlt(memDC, 0, 0, w, h, screenDC, r.Left, r.Top, SRCCOPY);
        SelectObject(memDC, oldBitmap);
        DeleteDC(memDC);
        ReleaseDC(IntPtr.Zero, screenDC);
        SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        if (ok) {
            var bmp = System.Drawing.Image.FromHbitmap(hBitmap);
            bmp.Save(path, System.Drawing.Imaging.ImageFormat.Png);
            bmp.Dispose();
        }
        DeleteObject(hBitmap);
        return ok;
    }
}
'@ -ReferencedAssemblies System.Drawing

# --- Helpers ---

function Find-Godot {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $patterns = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\Godot_v*_win64.exe"
        "$env:ProgramFiles\Godot\Godot*.exe"
        "C:\Godot\Godot*.exe"
    )
    foreach ($p in $patterns) {
        $found = Resolve-Path $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { return $found.Path }
    }
    return $null
}

function Wait-Window([string]$titlePrefix, [int]$timeoutMs = 20000) {
    $deadline = [DateTime]::UtcNow.AddMilliseconds($timeoutMs)
    while ([DateTime]::UtcNow -lt $deadline) {
        $hwnd = [Win32]::FindWindowStartsWith($titlePrefix)
        if ($hwnd -ne [IntPtr]::Zero) { return $hwnd }
        Start-Sleep -Milliseconds 500
    }
    return [IntPtr]::Zero
}

# --- Init ---

$godot = Find-Godot
if (-not $godot) {
    Write-Error "Godot not found. Run tools/setup/setup.bat first."
    exit 1
}

if ($ScreenshotDir -eq "") {
    $ScreenshotDir = Join-Path $ProjectPath "tools\screenshots"
}
$null = New-Item -ItemType Directory -Force -Path $ScreenshotDir

$report = [ordered]@{
    passed      = $false
    phases      = [ordered]@{}
    issues      = [System.Collections.Generic.List[string]]::new()
    screenshots = [System.Collections.Generic.List[string]]::new()
}

$shotCounter = 0

function Take-Screenshot([IntPtr]$hwnd, [string]$label) {
    $script:shotCounter++
    $safe = $label -replace '[^a-zA-Z0-9_-]', '_'
    $path = Join-Path $ScreenshotDir ("{0:D2}_{1}.png" -f $script:shotCounter, $safe)

    if ($ScreenshotTriggerPath -ne "") {
        # Godot-side screenshot: write output path to trigger file, wait for Godot to process it.
        # Use forward slashes: GDScript interprets backslashes as escape sequences.
        # Use ASCII (no BOM): Godot's FileAccess.get_line() doesn't strip BOM.
        $pathFwd = $path -replace '\\', '/'
        [System.IO.File]::WriteAllText($ScreenshotTriggerPath, $pathFwd + "`n",
            [System.Text.Encoding]::ASCII)
        $deadline = [DateTime]::UtcNow.AddMilliseconds(5000)
        while ([DateTime]::UtcNow -lt $deadline -and (Test-Path $ScreenshotTriggerPath)) {
            Start-Sleep -Milliseconds 30
        }
        Start-Sleep -Milliseconds 150  # brief wait for file flush
        if (Test-Path $path) {
            $report.screenshots.Add($path)
            Write-Host "  [screenshot] $label -> $path"
        } else {
            Write-Warning "  [screenshot] Godot screenshot not saved for: $label"
        }
    } else {
        # Fallback: BitBlt screen capture
        Start-Sleep -Milliseconds 400
        $ok = [Win32]::CaptureWindow([long]$hwnd, $path)
        if ($ok) {
            $report.screenshots.Add($path)
            Write-Host "  [screenshot] $label -> $path"
        } else {
            Write-Warning "  [screenshot] CaptureWindow failed for: $label"
        }
    }
    return $path
}

# ============================================================
# Phase 1 — Headless parse check
# ============================================================
Write-Host ""
Write-Host "[Phase 1] Headless parse check..."

$parseRaw = & $godot --headless --editor --path $ProjectPath --quit 2>&1
$parseOut = $parseRaw | Out-String

$scriptErrors = ($parseRaw | Where-Object {
    $_ -match "SCRIPT ERROR:|Parse Error:|GDScript Error:"
}) | ForEach-Object { $_.ToString().Trim() }

if ($scriptErrors) {
    foreach ($e in $scriptErrors) { $report.issues.Add($e) }
    $report.phases["1_parse"] = "FAILED"
    Write-Host "[Phase 1] FAILED - script errors found"
    $report | ConvertTo-Json -Depth 5
    exit 1
}
$report.phases["1_parse"] = "PASSED"
Write-Host "[Phase 1] PASSED - no parse errors"

# ============================================================
# Phase 2 — Launch + initial visual check
# ============================================================
Write-Host ""
Write-Host "[Phase 2] Launching game window..."

# Kill any existing Godot instances to avoid accumulating windows
Get-Process -Name "Godot*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 1000

$proc = Start-Process -FilePath $godot -ArgumentList "--path `"$ProjectPath`" --rendering-driver opengl3" -PassThru
$hwnd = Wait-Window -title $GameName -timeoutMs 25000

if ($hwnd -eq [IntPtr]::Zero) {
    $report.issues.Add("Game window '$GameName' did not appear within 25 seconds")
    $report.phases["2_launch"] = "FAILED"
    if ($proc -and -not $proc.HasExited) { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue }
    $report | ConvertTo-Json -Depth 5
    exit 1
}

Write-Host "[Phase 2] Window found (hwnd=$hwnd). Waiting for first render..."
[Win32]::ShowWindow($hwnd, [Win32]::SW_RESTORE) | Out-Null
Start-Sleep -Milliseconds 3000

Take-Screenshot -hwnd $hwnd -label "initial_launch" | Out-Null
$report.phases["2_launch"] = "PASSED"
Write-Host "[Phase 2] PASSED"

# ============================================================
# Phase 3 — Automated playthrough
# ============================================================
Write-Host ""
Write-Host "[Phase 3] Running playthrough ($($Playthrough.Count) steps)..."

foreach ($step in $Playthrough) {
    $t = $step.type

    if ($t -eq "hold") {
        if ($MovementTriggerPath -ne "") {
            # Godot-side movement: write trigger file, Godot calls Input.action_press()
            $dir = $step.key.ToLower()
            $durSec = [double]$step.duration_ms / 1000.0
            [System.IO.File]::WriteAllText($MovementTriggerPath, "$dir`n$durSec`n",
                [System.Text.Encoding]::ASCII)
            Start-Sleep -Milliseconds $step.duration_ms
        } else {
            $vk = [int]$VK[$step.key.ToLower()]
            [Win32]::HoldKeyBackground([long]$hwnd, $vk, [int]$step.duration_ms)
        }

    } elseif ($t -eq "press") {
        $vk = [int]$VK[$step.key.ToLower()]
        if ($InteractTriggerPath -ne "" -and $step.key.ToLower() -eq "e") {
            New-Item -ItemType File -Path $InteractTriggerPath -Force | Out-Null
        } else {
            [Win32]::PressKeyFocused([long]$hwnd, $vk)
        }

    } elseif ($t -eq "wait") {
        Start-Sleep -Milliseconds $step.duration_ms

    } elseif ($t -eq "screenshot") {
        Take-Screenshot -hwnd $hwnd -label $step.label | Out-Null
    }
}

$report.phases["3_playthrough"] = "PASSED"
Write-Host "[Phase 3] PASSED"

# ============================================================
# Phase 4 — Runtime log check
# ============================================================
Write-Host ""
Write-Host "[Phase 4] Checking runtime log..."
Start-Sleep -Milliseconds 1000

if ($proc -and -not $proc.HasExited) {
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1500
}

$logPath = "$env:APPDATA\Godot\app_userdata\$GameName\logs\godot.log"
if (Test-Path $logPath) {
    $logLines = Get-Content $logPath
    $runtimeErrors = $logLines | Where-Object { $_ -match "SCRIPT ERROR:|E \d+:" }
    if ($runtimeErrors) {
        foreach ($e in $runtimeErrors) { $report.issues.Add($e.Trim()) }
        $report.phases["4_log"] = "ERRORS_FOUND"
        Write-Host "[Phase 4] Runtime errors found in log"
    } else {
        $report.phases["4_log"] = "CLEAN"
        Write-Host "[Phase 4] CLEAN - no runtime errors"
    }
} else {
    $report.phases["4_log"] = "LOG_NOT_FOUND"
    Write-Host "[Phase 4] Log not found at: $logPath"
}

# ============================================================
# Summary
# ============================================================
$report.passed = $report.issues.Count -eq 0
Write-Host ""
Write-Host "=== Self-Check $( if ($report.passed) { 'PASSED' } else { 'FAILED' } ) ==="
Write-Host "Screenshots saved to: $ScreenshotDir"
Write-Host ""

$report | ConvertTo-Json -Depth 5
exit $(if ($report.passed) { 0 } else { 1 })
