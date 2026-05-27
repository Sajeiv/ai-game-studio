# Godot 4 — Export

How to export a completed Godot 4 project to web and desktop.

---

## Prerequisites

- Godot 4.6.3 installed
- Export templates installed (Editor → Manage Export Templates)
- For web export: Godot web export template installed

---

## Web export (HTML5)

Web export produces a playable build that runs in any modern browser.

### Export preset configuration

In `project.godot` or via the Export dialog, configure:

```
[export preset.0]
name="Web"
platform="Web"
runnable=true
export_path="build/web/index.html"

[export preset.0.options]
html/export_icon=true
html/custom_html_shell=""
progressive_web_app/enabled=false
```

### Export command

```
godot --headless --export-release "Web" build/web/index.html
```

The output directory `build/web/` will contain:
- `index.html` — entry point
- `index.js` — engine JavaScript
- `index.wasm` — engine binary
- `index.pck` — game data

### Serving the web build

The web build requires a server with correct MIME types and COOP/COEP headers. Use any static file server that sets:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

---

## Desktop export

### Windows

```
godot --headless --export-release "Windows Desktop" build/windows/game.exe
```

### macOS

```
godot --headless --export-release "macOS" build/macos/game.zip
```

### Linux

```
godot --headless --export-release "Linux" build/linux/game.x86_64
```

---

## Headless export in CI

For automated builds, run Godot with `--headless` and ensure export templates are installed before the build step. The Validator agent must pass cleanly before triggering export.

---

## Post-export checklist

- [ ] All audio streams included in export
- [ ] No missing texture references (check console for errors)
- [ ] Web build loads without SharedArrayBuffer errors
- [ ] Game starts from main scene with no crashes
