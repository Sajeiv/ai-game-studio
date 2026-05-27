# Skill: export_godot

## Purpose
Trigger a Godot 4 headless export of the game project to a target platform.

## Inputs
```json
{
  "project_path": "string — path to the Godot project folder",
  "platform": "web | windows | mac | linux",
  "output_path": "string — where to write the export"
}
```

## Outputs
- Exported build written to `output_path`
- `{ "success": true, "output_path": "string", "size_bytes": 0 }`

## Platforms
| Platform | Export template required | Output |
|----------|--------------------------|--------|
| `web` | Web export template | `.html` + `.wasm` + `.js` |
| `windows` | Windows export template | `.exe` |
| `mac` | macOS export template | `.app` |
| `linux` | Linux export template | binary |

## Requirements
- Godot 4 must be installed and accessible via the system PATH or `GODOT_PROJECTS_PATH`
- The correct export template must be installed in Godot
- `export_presets.cfg` must exist in the project (Engineer generates this)

## Notes
- Web export is the primary target for shareable game links
- Export is triggered by Producer after Validator passes
