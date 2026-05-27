# Seed: spawner

## What this seed does
Creates instances of a packed scene at runtime. Three modes: TIMER (spawns on a repeating interval), ON_DEMAND (spawns only when spawn() is called), and SIGNAL_TRIGGERED (spawns when a connected signal fires). Manages an optional pool cap to limit active instances.

## Inputs accepted
- `scene_to_spawn` — PackedScene resource to instantiate
- `spawn_mode` — TIMER, ON_DEMAND, SIGNAL_TRIGGERED (default TIMER)
- `spawn_interval` — seconds between spawns in TIMER mode (default 3.0)
- `max_instances` — maximum live instances at any time; 0 = unlimited (default 0)
- `spawn_positions` — Array of local Vector2 offsets; if empty, spawns at own position

## Outputs and signals
- `spawned(instance: Node)` — emitted each time an instance is created, passes the node
- `pool_full()` — emitted when max_instances is reached and a spawn was skipped
- `instance_freed(instance: Node)` — emitted when a spawned instance is queue_freed

## What it never does
- Does not configure the spawned instance after creation — use the spawned signal for that
- Does not handle AI, pathfinding, or behavior of spawned nodes
- Does not count destroyed instances toward score

## Usage example
Bullet hell boss: spawner on the boss, scene_to_spawn=bullet.tscn, spawn_mode=TIMER, spawn_interval=0.3, max_instances=40. A timer_event seed calls spawner.set_interval(0.1) at phase two to ramp up fire rate.
