# Seed: resource

## What this seed does
Tracks a numeric value clamped between a minimum and maximum. Models health, stamina, ammo, currency, score, or any countable quantity. Clamping is automatic. Emits signals at key thresholds (depleted, full, value changed) so other seeds can react.

## Inputs accepted
- `max_value` — maximum allowed value (default 100)
- `min_value` — minimum allowed value (default 0)
- `initial_value` — starting value; defaults to max_value if not set
- `resource_name` — identifier string carried in signals for disambiguation (default "resource")

## Outputs and signals
- `value_changed(new_value: float, old_value: float)` — emitted on any change
- `depleted()` — emitted when value reaches min_value
- `full()` — emitted when value reaches max_value

## What it never does
- Does not render anything — wire to ui_element for visual display
- Does not persist its value across sessions — use game_state or a save skill
- Does not decide what causes increases or decreases — external logic calls add() and subtract()

## Usage example
Player health: resource node named "health" on the player, max_value=100. A projectile's hit signal calls player.health.subtract(damage). resource emits value_changed, and the ui_element health bar listens to update its fill level. resource emits depleted() which the Engineer connects to GameState phase = LOSE.
