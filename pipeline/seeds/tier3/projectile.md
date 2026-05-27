# Seed: projectile

## What this seed does
Moves in a set direction at a constant speed and destroys itself on collision or after a maximum travel distance. Emits a hit signal with the colliding node so the Engineer can connect damage, sound, or particle effects without modifying this seed.

## Inputs accepted
- `speed` — movement speed in pixels per second (default 300)
- `direction` — initial travel direction as a Vector2 (default Vector2.RIGHT)
- `max_range` — maximum distance before auto-destroy; 0 = unlimited (default 400)
- `pierce_count` — number of targets to pass through before destroying (default 0)

## Outputs and signals
- `hit(target: Node, position: Vector2)` — emitted on each collision
- `max_range_reached()` — emitted when the projectile reaches its travel limit
- `destroyed()` — emitted just before queue_free so effects can be triggered

## What it never does
- Does not calculate or apply damage — connect the hit signal externally for that
- Does not spawn particles or effects internally — connect hit or destroyed for that
- Does not home in on targets — that behavior belongs in autonomous_mover

## Usage example
Shooter enemy: projectile instantiated by a spawner seed. At spawn time the direction is set to (player_position - spawn_position).normalized(). The Engineer connects hit to a function that calls player.health.subtract(damage_amount).
