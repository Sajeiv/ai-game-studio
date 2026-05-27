# Seed: detector

## What this seed does
Senses when a target enters, exits, or remains within range. Three modes: AREA (physics overlap zone), PROXIMITY (distance check on a timer), and RAYCAST (line-of-sight check on a timer). Only emits signals — takes no action itself.

## Inputs accepted
- `mode` — AREA, PROXIMITY, RAYCAST (default AREA)
- `detection_radius` — radius in pixels for PROXIMITY and RAYCAST modes (default 150)
- `target_group` — Godot group name to detect (default "player")
- `check_interval` — seconds between checks in PROXIMITY and RAYCAST modes (default 0.1)

## Outputs and signals
- `target_detected(target: Node)` — emitted the moment detection begins
- `target_lost(target: Node)` — emitted the moment detection ends
- `target_in_range(target: Node, distance: float)` — emitted each check interval while detection is active

## What it never does
- Does not move, attack, or change behavior — it only reports what it senses
- Does not modify game state
- Does not physically block movement or physics

## Usage example
Guard enemy: detector in RAYCAST mode on the guard node, target_group="player". When target_detected fires, the Engineer connects it to switch the autonomous_mover seed from PATROL mode to CHASE mode and assigns the detected node as the target.
