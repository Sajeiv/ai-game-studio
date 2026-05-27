# Seed: player_controller

## What this seed does
Reads player input and translates it into movement on the character body. Supports configurable speed, input map action names, and movement style (8-directional, 4-directional). Emits signals when movement state changes so other seeds can react without polling.

## Inputs accepted
- `speed` — movement speed in pixels per second (default 150)
- `input_left`, `input_right`, `input_up`, `input_down` — input action names (default ui_left, ui_right, ui_up, ui_down)
- `movement_style` — EIGHT_DIR or FOUR_DIR (default EIGHT_DIR)

## Outputs and signals
- `moved(direction: Vector2)` — emitted each frame the player is moving, carries the normalized direction vector
- `stopped()` — emitted the first frame the player stops moving

## What it never does
- Does not handle jumping, dashing, or special abilities
- Does not manage collision response beyond basic slide
- Does not read from game state or interact with other nodes
- Does not play animations or sounds

## Usage example
Horror escape: player_controller on the player CharacterBody2D, speed=120, movement_style=EIGHT_DIR. The autonomous_mover on the monster reads the player's position directly; it does not use this seed's signals.
