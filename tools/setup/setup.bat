@echo off
REM AI Game Studio — setup script for Windows
REM Run once after cloning the repo.

echo === AI Game Studio Setup ===
echo.

REM Check Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found. Install it from https://nodejs.org then re-run this script.
    exit /b 1
)
echo [OK] Node.js found.

REM Install MCP server dependencies
echo.
echo Installing pixellab-mcp dependencies...
cd /d "%~dp0..\pixellab-mcp"
npm install
if %errorlevel% neq 0 (
    echo [ERROR] npm install failed.
    exit /b 1
)
echo [OK] pixellab-mcp dependencies installed.

REM Copy .env.example if .env does not exist
cd /d "%~dp0..\.."
if not exist ".env" (
    copy ".env.example" ".env"
    echo [OK] .env created from .env.example — fill in your API keys before running.
) else (
    echo [OK] .env already exists.
)

echo.
echo Setup complete.
echo Next: open .env and fill in PIXELLAB_API_KEY and ANTHROPIC_API_KEY.
