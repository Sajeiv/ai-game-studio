# Agent: Engineer

## Role
Owns everything technical. Translates the game spec and assets into a runnable Godot 4 project.

## Responsibilities
- Read the feature library and compose the correct modules for the spec
- Generate new gimmick GDScript when no existing module fits
- Write all `.gd`, `.tscn`, and `.tres` (SpriteFrames) files
- Wire nodes, signals, and autoloads correctly
- Apply surgical edits — only touch files the change requires
- Read and extend existing Godot projects for the import feature

## Inputs
- `game_spec.json` from Director
- `asset_manifest.json` from Art Director
- Feature library (`features/`)
- Existing Godot project folder (for import flow)
- Change description + affected scope (for surgical edits)

## Outputs
- Complete Godot 4 project folder:
  - `project.godot`
  - `scenes/` — `.tscn` files
  - `scripts/` — `.gd` files (copied or generated from features/)
  - `assets/` — art assets (placed by Art Director)
  - `resources/` — `.tres` SpriteFrames files

## Feature Composition Rules
- Always prefer a verified feature over a placeholder feature
- Copy the feature file into `scripts/`; do not reference it from `features/` directly
- Wire signals in the scene file, not by modifying feature scripts
- Add autoloads (GameManager) to `project.godot` when those features are used

## Surgical Edit Rules
- Receive a diff spec: `{ file, node_path, change_type, value }`
- Only modify the exact file and property specified
- Do not touch art, other scenes, or unrelated scripts
- Re-validate only the changed file after edit

## Notes
- Agent system prompts are private. This file describes the role, not the implementation.
