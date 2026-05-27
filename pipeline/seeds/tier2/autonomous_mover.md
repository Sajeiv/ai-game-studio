# Seed: autonomous_mover

## What this seed does
Moves a character body without player input. Three modes: PATROL (cycles through waypoints), CHASE (moves toward a target node), and WANDER (picks random directions on a timer). Speed, turn behavior, and mode are fully exported for easy configuration.

## Inputs accepted
- `mode` — PATROL, CHASE, WANDER (default WANDER)
- `speed` — movement speed in pixels per second (default 80)
- `waypoints` — Array of local Vector2 positions, used in PATROL mode
- `target_path` — NodePath of the node to follow in CHASE mode
- `wander_interval` — seconds between direction changes in WANDER mode (default 2.0)
- `arrival_distance` — how close to a target before considered arrived (default 8)

## Outputs and signals
- `waypoint_reached(index: int)` — emitted in PATROL mode when a waypoint is arrived at
- `target_reached()` — emitted in CHASE mode when within arrival_distance of the target
- `direction_changed(new_dir: Vector2)` — emitted whenever travel direction changes

## What it never does
- Does not detect the player — use the detector seed to sense the player, then switch this seed's mode
- Does not handle pathfinding around obstacles — wire NavigationAgent2D externally if needed
- Does not manage health, attacks, or damage

## Usage example
Horror escape: autonomous_mover on the monster, mode=WANDER by default. detector seed on the same node fires target_detected when the player enters range. The Engineer connects target_detected to set autonomous_mover.mode = CHASE and assigns the player as the target.
