#!/usr/bin/env bash
# AI Game Studio — macOS / Linux setup script
# Run once after cloning the repo.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REPO_ROOT_FWD="$REPO_ROOT"

echo "=== AI Game Studio Setup ==="
echo ""

# -----------------------------------------------------------------------
# Node.js
# -----------------------------------------------------------------------
if ! command -v node &>/dev/null; then
    echo "[ERROR] Node.js not found."
    echo "        Install it from https://nodejs.org or via your package manager, then re-run."
    exit 1
fi
echo "[OK] Node.js $(node --version) found."

# -----------------------------------------------------------------------
# Godot 4
# -----------------------------------------------------------------------
echo ""
echo "Checking for Godot 4..."

GODOT_CMD=""

find_godot() {
    for cmd in godot godot4 godot-4; do
        if command -v "$cmd" &>/dev/null; then
            GODOT_CMD="$cmd"
            return 0
        fi
    done
    # macOS: check Applications folder
    if [[ "$OSTYPE" == "darwin"* ]]; then
        for app in "/Applications/Godot.app" "/Applications/Godot_4.app"; do
            if [[ -d "$app" ]]; then
                GODOT_CMD="$app/Contents/MacOS/Godot"
                return 0
            fi
        done
    fi
    return 1
}

if find_godot; then
    GODOT_VER="$($GODOT_CMD --version 2>/dev/null || echo "unknown")"
    echo "[OK] Godot $GODOT_VER found."
else
    echo "Godot 4 not found. Installing..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS — use Homebrew
        if command -v brew &>/dev/null; then
            echo "Installing via Homebrew..."
            brew install --cask godot
        else
            echo "[ERROR] Homebrew not found."
            echo "        Install Homebrew (https://brew.sh) then re-run, or"
            echo "        download Godot from https://godotengine.org/download"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux — try snap first, then flatpak
        if command -v snap &>/dev/null; then
            echo "Installing via snap..."
            sudo snap install godot-4 --classic
        elif command -v flatpak &>/dev/null; then
            echo "Installing via flatpak..."
            flatpak install flathub org.godotengine.Godot -y
            # Create a wrapper so 'godot' works from terminal
            mkdir -p "$HOME/.local/bin"
            printf '#!/bin/sh\nflatpak run org.godotengine.Godot "$@"\n' > "$HOME/.local/bin/godot"
            chmod +x "$HOME/.local/bin/godot"
        else
            echo "[ERROR] Neither snap nor flatpak found."
            echo "        Download Godot from https://godotengine.org/download"
            echo "        Extract the binary and add it to your PATH, then re-run."
            exit 1
        fi
    else
        echo "[ERROR] Unsupported OS: $OSTYPE"
        echo "        Download Godot from https://godotengine.org/download"
        exit 1
    fi

    if find_godot; then
        GODOT_VER="$($GODOT_CMD --version 2>/dev/null || echo "unknown")"
        echo "[OK] Godot $GODOT_VER installed."
    else
        echo "[WARN] Could not verify Godot installation. You may need to open a new terminal."
    fi
fi

# -----------------------------------------------------------------------
# pixellab-mcp Node.js dependencies
# -----------------------------------------------------------------------
echo ""
echo "Installing pixellab-mcp dependencies..."
cd "$REPO_ROOT/tools/pixellab-mcp"
npm install --silent
echo "[OK] pixellab-mcp dependencies installed."

# -----------------------------------------------------------------------
# .env setup
# -----------------------------------------------------------------------
cd "$REPO_ROOT"

if [[ ! -f ".env" ]]; then
    cp ".env.example" ".env"
    echo "[OK] .env created from .env.example"
else
    echo "[OK] .env already exists."
fi

# Auto-fill GAME_STUDIO_PATH if currently empty
if grep -qE '^GAME_STUDIO_PATH=$' .env; then
    sed -i.bak "s|^GAME_STUDIO_PATH=$|GAME_STUDIO_PATH=$REPO_ROOT_FWD|" .env && rm -f .env.bak
    echo "[OK] GAME_STUDIO_PATH = $REPO_ROOT_FWD"
fi

# Auto-fill GODOT_PROJECTS_PATH to games/ subfolder if currently empty
GAMES_PATH="$REPO_ROOT_FWD/games"
if grep -qE '^GODOT_PROJECTS_PATH=$' .env; then
    sed -i.bak "s|^GODOT_PROJECTS_PATH=$|GODOT_PROJECTS_PATH=$GAMES_PATH|" .env && rm -f .env.bak
    echo "[OK] GODOT_PROJECTS_PATH = $GAMES_PATH"
fi

# -----------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------
echo ""
echo "============================================================"
echo " Setup complete!"
echo "============================================================"
echo ""
echo " Next steps:"
echo "   1. Open .env and add your API keys:"
echo "        PIXELLAB_API_KEY   — https://pixellab.ai"
echo "        ANTHROPIC_API_KEY  — https://console.anthropic.com"
echo "   2. Open Claude Code in this folder and describe your game."
echo ""
