#Requires -Version 5.1
<#
.SYNOPSIS
    Low-level action primitives for the AI playtester agent.
    The AI calls each action individually, guided by vision, not a script.

.DESCRIPTION
    Exposes five actions the Validator agent calls one at a time:
      launch     — start the game, return the window handle
      screenshot — capture the current frame, return the saved path
      press      — tap a key once
      hold       — hold a key for N milliseconds
      stop       — kill the game process

    The AI decides what to do next by reading each screenshot with its vision.
    No playthrough sequence is hardcoded here.

.PARAMETER Action
    One of: launch | screenshot | press | hold | stop

.PARAMETER ProjectPath
    Absolute path to the Godot project folder (contains project.godot).

.PARAMETER GameName
    Window title prefix used to find the game window (e.g. "Mystery Mansion").

.PARAMETER Key
    Key name for press/hold actions: up | down | left | right | e | space | enter | escape | shift

.PARAMETER Ms
    Duration in milliseconds for hold and wait actions.

.PARAMETER Label
    Descriptive label for the screenshot filename.

.PARAMETER ScreenshotDir
    Where to save screenshots. Default: $ProjectPath\tools\screenshots

.PARAMETER Hwnd
    Window handle returned by the launch action. Pass to subsequent actions.

.EXAMPLE
    # Launch
    $hwnd = & tools\playtest_actions.ps1 -Action launch -ProjectPath "..." -GameName "Mystery Mansion"

    # Screenshot + read with vision
    $path = & tools\playtest_actions.ps1 -Action screenshot -ProjectPath "..." -Hwnd $hwnd -Label "main_menu"

    # Press a key
    & tools\playtest_actions.ps1 -Action press -Hwnd $hwnd -Key e

    # Hold a direction
    & tools\playtest_actions.ps1 -Action hold -Hwnd $hwnd -Key down -Ms 2000

    # Stop
    & tools\playtest_actions.ps1 -Action stop -Hwnd $hwnd
#>
param(
    [Parameter(Mandatory)] [ValidateSet("launch","screenshot","press","hold","stop","wait")]
    [string] $Action,

    [string] $ProjectPath  = "",
    [string] $GameName     = "",
    [string] $Key          = "",
    [int]    $Ms           = 500,
    [string] $Label        = "frame",
    [string] $ScreenshotDir = "",
    [long]   $Hwnd         = 0
)

$ErrorActionPreference = "Stop"

# ── Win32 types ─────────────────────────────────────────────────────────────
if (-not ([System.Management.Automation.PSTypeName]"PlaytestWin32").Type) {
    Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Text;

public static class PlaytestWin32 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr lp);
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder sb, int n);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int n);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr hAfter, int x, int y, int cx, int cy, uint f);
    [DllImport("user32.dll")] public static extern int  GetWindowThreadProcessId(IntPtr h, out int pid);
    [DllImport("kernel32.dll")] public static extern int GetCurrentThreadId();
    [DllImport("user32.dll")] public static extern bool AttachThreadInput(int a, int b, bool attach);
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, int msg, int wp, uint lp);
    [DllImport("user32.dll")] public static extern IntPtr SendMessageW(IntPtr h, int msg, IntPtr wp, IntPtr lp);
    [DllImport("gdi32.dll")]  public static extern IntPtr CreateCompatibleDC(IntPtr hdc);
    [DllImport("gdi32.dll")]  public static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int w, int h);
    [DllImport("gdi32.dll")]  public static extern IntPtr SelectObject(IntPtr hdc, IntPtr obj);
    [DllImport("gdi32.dll")]  public static extern bool DeleteDC(IntPtr hdc);
    [DllImport("gdi32.dll")]  public static extern bool DeleteObject(IntPtr obj);
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr hWnd, IntPtr hdc);
    [DllImport("gdi32.dll")]  public static extern bool BitBlt(IntPtr dst, int x, int y, int w, int h, IntPtr src, int sx, int sy, int rop);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    public const int  SW_RESTORE   = 9;
    public const int  WM_KEYDOWN   = 0x0100;
    public const int  WM_KEYUP     = 0x0101;
    public const int  SRCCOPY      = 0x00CC0020;
    public static readonly IntPtr HWND_TOPMOST   = new IntPtr(-1);
    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    public const uint SWP_NOMOVE   = 0x0002;
    public const uint SWP_NOSIZE   = 0x0001;
    public const uint SWP_NOACT    = 0x0010;

    static bool IsExt(int vk) { return vk==0x25||vk==0x26||vk==0x27||vk==0x28||vk==0xA0; }

    static void Focus(IntPtr hwnd) {
        int pid; int tid = GetWindowThreadProcessId(hwnd, out pid);
        int me = GetCurrentThreadId();
        ShowWindow(hwnd, SW_RESTORE);
        AttachThreadInput(me, tid, true);
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(80);
        AttachThreadInput(me, tid, false);
    }

    public static void HoldKey(long hwndL, int vk, int ms) {
        var hwnd = new IntPtr(hwndL);
        Focus(hwnd);
        uint dn = 0x00000001u | (IsExt(vk) ? 0x01000000u : 0u);
        uint up = 0xC0000001u | (IsExt(vk) ? 0x01000000u : 0u);
        PostMessage(hwnd, WM_KEYDOWN, vk, dn);
        System.Threading.Thread.Sleep(ms);
        PostMessage(hwnd, WM_KEYUP,   vk, up);
    }

    public static void PressKey(long hwndL, int vk) {
        var hwnd = new IntPtr(hwndL);
        int pid; int tid = GetWindowThreadProcessId(hwnd, out pid);
        int me = GetCurrentThreadId();
        ShowWindow(hwnd, SW_RESTORE);
        AttachThreadInput(me, tid, true);
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(100);
        uint dn = 0x00000001u | (IsExt(vk) ? 0x01000000u : 0u);
        uint up = 0xC0000001u | (IsExt(vk) ? 0x01000000u : 0u);
        SendMessageW(hwnd, WM_KEYDOWN, new IntPtr(vk), new IntPtr((long)dn));
        System.Threading.Thread.Sleep(80);
        SendMessageW(hwnd, WM_KEYUP,   new IntPtr(vk), new IntPtr((long)up));
        System.Threading.Thread.Sleep(120);
        AttachThreadInput(me, tid, false);
    }

    public static string Capture(long hwndL, string path) {
        var hwnd = new IntPtr(hwndL);
        RECT r; if (!GetWindowRect(hwnd, out r)) return "";
        int w = r.Right - r.Left, h = r.Bottom - r.Top;
        if (w <= 0 || h <= 0) return "";
        SetWindowPos(hwnd, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE|SWP_NOSIZE|SWP_NOACT);
        Focus(hwnd);
        System.Threading.Thread.Sleep(400);
        IntPtr scrDC = GetDC(IntPtr.Zero);
        IntPtr memDC = CreateCompatibleDC(scrDC);
        IntPtr bmp   = CreateCompatibleBitmap(scrDC, w, h);
        IntPtr old   = SelectObject(memDC, bmp);
        bool ok = BitBlt(memDC, 0,0,w,h, scrDC, r.Left, r.Top, SRCCOPY);
        SelectObject(memDC, old); DeleteDC(memDC); ReleaseDC(IntPtr.Zero, scrDC);
        SetWindowPos(hwnd, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE|SWP_NOSIZE|SWP_NOACT);
        if (ok) {
            var img = System.Drawing.Image.FromHbitmap(bmp);
            img.Save(path, System.Drawing.Imaging.ImageFormat.Png);
            img.Dispose();
        }
        DeleteObject(bmp);
        return ok ? path : "";
    }

    public static IntPtr FindWindow(string prefix) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((hwnd, lp) => {
            if (!IsWindowVisible(hwnd)) return true;
            var sb = new StringBuilder(256);
            GetWindowText(hwnd, sb, 256);
            if (sb.ToString().StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) {
                found = hwnd; return false;
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }
}
'@ -ReferencedAssemblies System.Drawing
}

# ── Key map ─────────────────────────────────────────────────────────────────
$VK = @{
    up     = 0x26; down  = 0x28; left  = 0x25; right = 0x27
    e      = 0x45; space = 0x20; enter = 0x0D; escape = 0x1B
    shift  = 0xA0; r     = 0x52; w     = 0x57; a     = 0x41
    s      = 0x53; d     = 0x44
}

# ── Godot finder ─────────────────────────────────────────────────────────────
function Find-Godot {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $patterns = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*\Godot_v*_win64.exe"
        "$env:ProgramFiles\Godot\Godot*.exe"
    )
    foreach ($p in $patterns) {
        $f = Resolve-Path $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($f) { return $f.Path }
    }
    return $null
}

# ── Screenshot dir ───────────────────────────────────────────────────────────
if ($ScreenshotDir -eq "" -and $ProjectPath -ne "") {
    $ScreenshotDir = Join-Path $ProjectPath "tools\screenshots"
}
if ($ScreenshotDir -ne "") {
    $null = New-Item -ItemType Directory -Force -Path $ScreenshotDir
}

$shotCounter = 0
if ($ScreenshotDir -ne "") {
    $existing = Get-ChildItem $ScreenshotDir -Filter "*.png" -ErrorAction SilentlyContinue
    $shotCounter = if ($existing) { $existing.Count } else { 0 }
}

# ── Actions ──────────────────────────────────────────────────────────────────

switch ($Action) {

    "launch" {
        $godot = Find-Godot
        if (-not $godot) { Write-Error "Godot not found."; exit 1 }

        # Kill stale Godot windows
        Get-Process -Name "Godot*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800

        Start-Process -FilePath $godot -ArgumentList "--path `"$ProjectPath`" --rendering-driver opengl3"

        # Wait for window
        $deadline = [DateTime]::UtcNow.AddSeconds(25)
        $hwnd = [IntPtr]::Zero
        while ([DateTime]::UtcNow -lt $deadline) {
            $hwnd = [PlaytestWin32]::FindWindow($GameName)
            if ($hwnd -ne [IntPtr]::Zero) { break }
            Start-Sleep -Milliseconds 500
        }
        if ($hwnd -eq [IntPtr]::Zero) { Write-Error "Game window '$GameName' did not appear."; exit 1 }

        Start-Sleep -Milliseconds 2500   # let first frame render
        # Return the hwnd as a long so the caller can pass it back
        Write-Output ([long]$hwnd)
    }

    "screenshot" {
        if ($Hwnd -eq 0) { Write-Error "-Hwnd required for screenshot."; exit 1 }
        $shotCounter++
        $safe = $Label -replace '[^a-zA-Z0-9_-]','_'
        $path = Join-Path $ScreenshotDir ("{0:D2}_{1}.png" -f $shotCounter, $safe)
        $result = [PlaytestWin32]::Capture($Hwnd, $path)
        if ($result -eq "") { Write-Error "Capture failed."; exit 1 }
        Write-Output $result   # return path so caller can read it with vision
    }

    "press" {
        if ($Hwnd -eq 0) { Write-Error "-Hwnd required for press."; exit 1 }
        $vk = $VK[$Key.ToLower()]
        if (-not $vk) { Write-Error "Unknown key '$Key'."; exit 1 }
        [PlaytestWin32]::PressKey($Hwnd, $vk)
    }

    "hold" {
        if ($Hwnd -eq 0) { Write-Error "-Hwnd required for hold."; exit 1 }
        $vk = $VK[$Key.ToLower()]
        if (-not $vk) { Write-Error "Unknown key '$Key'."; exit 1 }
        [PlaytestWin32]::HoldKey($Hwnd, $vk, $Ms)
    }

    "wait" {
        Start-Sleep -Milliseconds $Ms
    }

    "stop" {
        Get-Process -Name "Godot*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Output "stopped"
    }
}
