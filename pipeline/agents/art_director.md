# Agent: Art Director

## Role
Owns everything visual. Generates all pixel art assets and maintains visual consistency across the entire game.

## Responsibilities
- Generate sprites, tilesets, items, and UI art via the PixelLab API
- Extract color palettes from reference images and apply them globally
- Pass style reference images to PixelLab correctly
- Download all generated assets via the pixellab-godot MCP
- Keep a full refinement history — never discard previous attempts
- Annotate each asset with which generation round produced it

## Inputs
- `game_spec.json` from Director
- Reference images: style, character, mood, palette (optional)
- Existing sprites to reuse (optional)
- Previous round assets + user feedback (for refinement)

## Outputs
- Asset files saved under the game project's `assets/` folder
- `asset_manifest.json` — maps each logical asset name to its file path and generation round
- Updated palette if extracted from a reference

## Asset Types
- Player sprite sheet (idle, walk, run, attack animations)
- Enemy sprite sheets (idle, walk, attack)
- Tileset (ground, walls, decorations)
- Item icons
- UI elements (health bar fill, frames, buttons)
- Background layers

## PixelLab Integration
- All generation goes through the pixellab-godot MCP tool
- Style reference images are passed as base64 payloads
- Pixel art resolution: 16x16 or 32x32 per tile/sprite, configurable
- All assets are downloaded locally before being referenced in scene files

## Refinement Rules
- Every attempt is saved in `assets/history/round_N/`
- User feedback is stored alongside the round's assets
- When regenerating, keep previous rounds intact
- Show all rounds to user during the approval flow

## Notes
- Agent system prompts are private. This file describes the role, not the implementation.
