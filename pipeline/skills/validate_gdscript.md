# Skill: validate_gdscript

## Purpose
Check a GDScript file for syntax errors and common structural issues before the game runs.

## Inputs
- `file_path` — path to the `.gd` file
- `scene_context` — optional list of node names available in the attached scene

## Outputs
```json
{
  "valid": true,
  "errors": [
    { "line": 0, "message": "string", "severity": "error | warning" }
  ]
}
```

## Checks Performed

### Syntax and structural
- GDScript syntax (parse-level errors)
- `@onready` paths that reference nodes not in `scene_context`
- Calls to `OS.execute()` — blocked, see community submission rules
- `FileAccess` paths outside `res://` or `user://`
- HTTP request calls — blocked in community modules
- Undefined variable references
- Signals emitted but never declared
- Methods called on potentially null nodes without null checks
- Variables re-declared that already exist in a parent class (`@export var` override → GDScript 4 parse error "Variable already defined in parent class"). Fix: remove the re-declaration; set the value in `_ready()` and call `super._ready()`.

### Visual sanity checks (run after syntax is clean)

These checks prevent invisible or broken layouts at runtime:

**Viewport size**
- Confirm `project.godot` sets `viewport_width=1280` and `viewport_height=720`
- Flag any `window/stretch/mode` entry — it should not be present unless pixel art aesthetic was explicitly requested

**Camera zoom**
- Flag Camera2D `zoom_level` values below `Vector2(1.0, 1.0)` — these zoom OUT and may show outside the world boundary
- Flag zoom values above `Vector2(3.0, 3.0)` — these zoom IN so far the player may be unable to navigate

**Dialogue box sizing**
- Any `RichTextLabel` inside a dialogue seed's `PanelContainer` must have `custom_minimum_size` ≥ `Vector2(1000, 100)` for a 1280 × 720 viewport
- Values below `Vector2(300, 60)` will render as a tiny sliver — flag and fix

**HUD label font sizes**
- HUD counter labels (score, clues, health) should use `font_size` ≥ 18
- Values ≤ 9 are unreadable at 1280 × 720 — flag and fix to 20

**NPC/object name labels**
- Labels positioned above sprites should have `position.y` ≤ -40 to clear the sprite (32 px tall sprites → label at y=-48 or higher)

### Headless parse check (optional, if Godot is on PATH)

Run this to catch any remaining parse errors that the static checker misses:

```powershell
$godot = (Get-Command godot -ErrorAction SilentlyContinue)?.Source
if ($godot) {
    & $godot --headless --editor --path <project_dir> --quit 2>&1 | Select-String "ERROR:|SCRIPT ERROR:"
}
```

An empty result means no parse errors.
