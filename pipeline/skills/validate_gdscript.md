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
- GDScript syntax (parse-level errors)
- `@onready` paths that reference nodes not in `scene_context`
- Calls to `OS.execute()` — blocked, see community submission rules
- `FileAccess` paths outside `res://` or `user://`
- HTTP request calls — blocked in community modules
- Undefined variable references
- Signals emitted but never declared
- Methods called on potentially null nodes without null checks
