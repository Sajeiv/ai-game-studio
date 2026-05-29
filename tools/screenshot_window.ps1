#Requires -Version 5.1
<#
.SYNOPSIS
    Standalone utility: capture a named window to a PNG file.

.PARAMETER WindowTitle
    Exact title of the window to capture.

.PARAMETER OutputPath
    Where to write the PNG. Parent directory must exist.

.EXAMPLE
    .\screenshot_window.ps1 -WindowTitle "The Village Secret" -OutputPath "C:\tmp\shot.png"
#>
param(
    [Parameter(Mandatory)] [string] $WindowTitle,
    [Parameter(Mandatory)] [string] $OutputPath
)

Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class ScreenCapture {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr FindWindow(string cls, string title);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT r);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmd);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    public static bool Capture(string title, string path) {
        var hwnd = FindWindow(null, title);
        if (hwnd == IntPtr.Zero) return false;
        ShowWindow(hwnd, 9); // SW_RESTORE
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(300);
        RECT r;
        if (!GetWindowRect(hwnd, out r)) return false;
        int w = r.Right - r.Left, h = r.Bottom - r.Top;
        if (w <= 0 || h <= 0) return false;
        using (var bmp = new Bitmap(w, h))
        using (var g = Graphics.FromImage(bmp)) {
            g.CopyFromScreen(r.Left, r.Top, 0, 0, new Size(w, h));
            bmp.Save(path, ImageFormat.Png);
        }
        return true;
    }
}
'@ -ReferencedAssemblies System.Drawing

$ok = [ScreenCapture]::Capture($WindowTitle, $OutputPath)
if ($ok) {
    Write-Host "Screenshot saved: $OutputPath"
    exit 0
} else {
    Write-Error "Window '$WindowTitle' not found or capture failed."
    exit 1
}
