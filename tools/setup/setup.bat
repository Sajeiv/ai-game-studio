@echo off
setlocal enabledelayedexpansion
REM AI Game Studio — Windows setup script
REM Run once after cloning the repo.

echo === AI Game Studio Setup ===
echo.

REM -----------------------------------------------------------------------
REM Node.js
REM -----------------------------------------------------------------------
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found.
    echo         Download and install it from https://nodejs.org then re-run this script.
    exit /b 1
)
for /f "tokens=*" %%v in ('node --version') do set NODE_VER=%%v
echo [OK] Node.js %NODE_VER% found.

REM -----------------------------------------------------------------------
REM Godot 4
REM -----------------------------------------------------------------------
echo.
echo Checking for Godot 4...

set GODOT_CMD=
set GODOT_PATH=

REM Check PATH first
where godot >nul 2>&1
if %errorlevel% equ 0 (
    set GODOT_CMD=godot
    goto :godot_found
)
where godot4 >nul 2>&1
if %errorlevel% equ 0 (
    set GODOT_CMD=godot4
    goto :godot_found
)

REM Check common install locations left by winget / Godot installer
for /f "delims=" %%p in ('dir /b /s "%LOCALAPPDATA%\Programs\Godot*\*.exe" 2^>nul ^| findstr /i "godot" ^| findstr /v "console"') do (
    set GODOT_PATH=%%p
    goto :godot_found_by_path
)
for /f "delims=" %%p in ('dir /b /s "%PROGRAMFILES%\Godot*\*.exe" 2^>nul ^| findstr /i "godot" ^| findstr /v "console"') do (
    set GODOT_PATH=%%p
    goto :godot_found_by_path
)

REM Not found — install via winget
echo Godot 4 not found. Installing via winget...
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] winget not available. Install Godot 4 manually from https://godotengine.org/download
    echo         Then re-run this script.
    exit /b 1
)

winget install GodotEngine.GodotEngine --silent --accept-package-agreements --accept-source-agreements
if %errorlevel% neq 0 (
    echo [WARN] winget returned a non-zero exit code. Checking if Godot was installed anyway...
)

REM Re-check PATH (winget may have added it)
where godot >nul 2>&1
if %errorlevel% equ 0 (
    set GODOT_CMD=godot
    goto :godot_found
)

REM Check WinGet packages directory (where winget extracts portable apps)
for /f "delims=" %%p in ('dir /b /s "%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine*\*.exe" 2^>nul ^| findstr /i "godot" ^| findstr /v "console"') do (
    set GODOT_PATH=%%p
    goto :godot_found_by_path
)

REM Re-check Programs locations
for /f "delims=" %%p in ('dir /b /s "%LOCALAPPDATA%\Programs\Godot*\*.exe" 2^>nul ^| findstr /i "godot" ^| findstr /v "console"') do (
    set GODOT_PATH=%%p
    goto :godot_found_by_path
)

echo [WARN] Godot installation could not be verified automatically.
echo        Open a new terminal and re-run this script, or install manually from https://godotengine.org/download
goto :godot_done

:godot_found_by_path
set GODOT_CMD=!GODOT_PATH!
echo [OK] Godot found at !GODOT_PATH!
REM Create a godot.bat shim in the same folder so 'godot' works from any terminal
for /f "delims=" %%d in ('echo !GODOT_PATH!') do set GODOT_DIR=%%~dpd
echo @echo off > "!GODOT_DIR!godot.bat"
echo "!GODOT_PATH!" %%* >> "!GODOT_DIR!godot.bat"
echo [OK] Created godot.bat shim for PATH access.
goto :godot_done

:godot_found
for /f "tokens=*" %%v in ('!GODOT_CMD! --version 2^>nul') do set GODOT_VER=%%v
echo [OK] Godot !GODOT_VER! found.

:godot_done

REM -----------------------------------------------------------------------
REM pixellab-mcp Node.js dependencies
REM -----------------------------------------------------------------------
echo.
echo Installing pixellab-mcp dependencies...
cd /d "%~dp0..\pixellab-mcp"
call npm install --silent
if %errorlevel% neq 0 (
    echo [ERROR] npm install failed.
    exit /b 1
)
echo [OK] pixellab-mcp dependencies installed.

REM -----------------------------------------------------------------------
REM .env setup
REM -----------------------------------------------------------------------
cd /d "%~dp0..\.."

if not exist ".env" (
    copy ".env.example" ".env" >nul
    echo [OK] .env created from .env.example
) else (
    echo [OK] .env already exists.
)

REM Resolve repo root as a forward-slash path for .env
for %%i in ("%CD%") do set REPO_ROOT=%%~fi
set REPO_ROOT_FWD=%REPO_ROOT:\=/%

REM Auto-fill GAME_STUDIO_PATH and GODOT_PROJECTS_PATH if currently empty
REM Uses \r?$ to handle both CRLF and LF line endings
set GAMES_PATH_FWD=%REPO_ROOT_FWD%/games
powershell -NoProfile -Command "$f = '%CD%\.env'; $c = [IO.File]::ReadAllText($f); $c = $c -replace '(?m)^GAME_STUDIO_PATH=\r?$', 'GAME_STUDIO_PATH=%REPO_ROOT_FWD%'; $c = $c -replace '(?m)^GODOT_PROJECTS_PATH=\r?$', 'GODOT_PROJECTS_PATH=%GAMES_PATH_FWD%'; [IO.File]::WriteAllText($f, $c)"
echo [OK] GAME_STUDIO_PATH = %REPO_ROOT_FWD%
echo [OK] GODOT_PROJECTS_PATH = %GAMES_PATH_FWD%

REM -----------------------------------------------------------------------
REM Done
REM -----------------------------------------------------------------------
echo.
echo ============================================================
echo  Setup complete!
echo ============================================================
echo.
echo  Next steps:
echo    1. Open .env and add your API keys:
echo         PIXELLAB_API_KEY   — https://pixellab.ai
echo         ANTHROPIC_API_KEY  — https://console.anthropic.com
echo    2. Open Claude Code in this folder and describe your game.
echo.
if defined GODOT_PATH (
    echo  TIP: Add Godot to your PATH for easier CLI access:
    echo       %GODOT_PATH%
    echo.
)
endlocal
