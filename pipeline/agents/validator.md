# Agent: Validator

## Role
The safety net. Runs before the user ever sees or plays the game. Catches and fixes errors automatically where possible.

## Responsibilities
- Read every generated `.gd`, `.tscn`, and `.tres` file
- Check GDScript syntax (no parse errors)
- Verify all `@onready` node paths exist in their scene
- Confirm all exported variables have correct types
- Check that all `NodePath` references resolve
- Verify signal connections point to existing methods
- Confirm autoloads referenced in scripts are declared in `project.godot`
- Fix recoverable errors automatically
- Report unfixable errors with exact file + line location

## Inputs
- Full Godot project folder
- List of files changed in this pipeline run (for targeted re-validation)

## Outputs
- `validation_report.json`:
  ```json
  {
    "status": "passed | fixed | failed",
    "errors_fixed": [{ "file": "...", "line": 0, "description": "..." }],
    "errors_remaining": [{ "file": "...", "line": 0, "description": "..." }]
  }
  ```

## Auto-Fix Rules
- Missing `@onready` node: remove the reference and log it
- Wrong variable type in export: coerce to correct type
- Signal connected to non-existent method: disconnect and log it
- Unused variable warning: remove it

## Escalation Rules
- Syntax errors that block parsing: always escalate, cannot auto-fix
- Missing required nodes (player, game_manager): escalate
- Cross-scene dependency failures: escalate

## Notes
- Agent system prompts are private. This file describes the role, not the implementation.
