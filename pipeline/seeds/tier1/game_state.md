# Seed: game_state

## What this seed does
Tracks global game phase (MENU, PLAYING, PAUSED, WIN, LOSE) and an arbitrary dictionary of named flags. Emits signals when phase or any flag changes so other seeds can react without direct coupling. Registers as an autoload singleton.

## Inputs accepted
- `initial_flags` — Dictionary of starting flag values, set before the scene runs
- `start_phase` — starting GamePhase value (default PLAYING)

## Outputs and signals
- `phase_changed(new_phase: GamePhase)` — emitted whenever the phase changes
- `flag_changed(key: String, value: Variant)` — emitted whenever any flag is written
- `game_won()` — convenience signal, fires when phase becomes WIN
- `game_lost()` — convenience signal, fires when phase becomes LOSE

## What it never does
- Does not save to disk — use a separate save skill for persistence
- Does not directly modify or control any node — only stores state and emits signals
- Does not own scene transitions — connect its signals to scene_manager for that

## Usage example
Horror escape: game_state starts with flags {keys_found: 0, door_unlocked: false}. When the player picks up a key, the interactable seed calls GameState.set_flag("keys_found", n+1). The door's interactable listens to flag_changed to unlock when the count reaches the required number.
