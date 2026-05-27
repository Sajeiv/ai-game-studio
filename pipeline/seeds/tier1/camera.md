# Seed: camera

## What this seed does
Follows a target node smoothly using lerp-based interpolation. Respects configurable world bounds so the camera never shows outside the level. Supports zoom levels and exposes methods for shake, zoom-to, and pan-to-point operations.

## Inputs accepted
- `target` — node path to follow (typically the player)
- `smoothing_speed` — how fast the camera catches up, higher = snappier (default 5.0)
- `zoom_level` — camera zoom as Vector2 (default Vector2.ONE)
- `use_bounds` — whether to clamp camera within bounds_rect (default false)
- `bounds_rect` — Rect2 defining the clamped world area

## Outputs and signals
- `zoom_changed(zoom: Vector2)` — emitted when zoom is updated
- `bounds_reached(side: String)` — emitted when the camera hits a boundary edge

## What it never does
- Does not define the level bounds — those come from the level scene
- Does not handle split-screen or multiple camera viewports
- Does not control rendering layers or visibility

## Usage example
Platformer: camera node follows the player path. smoothing_speed=8. bounds_rect set to the tile map extents so the camera never shows black space outside the level.
