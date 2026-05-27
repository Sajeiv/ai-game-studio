# Seed: interactable

## What this seed does
Makes a node respond when the player presses an interact key while within range. Shows an optional prompt label when the player is nearby. Supports one-shot interactions that disable after first use, and repeatable interactions. Emits a signal that the Engineer connects to the appropriate game logic.

## Inputs accepted
- `prompt_text` — label shown near the node when the player is in range (default "Press E")
- `interact_action` — input action name to listen for (default "interact")
- `one_shot` — if true, disables itself permanently after the first interaction (default false)
- `interaction_radius` — distance in pixels within which interaction is possible (default 48)

## Outputs and signals
- `interacted(interactor: Node)` — emitted when the player presses interact while in range
- `player_entered_range()` — emitted when a player enters the interaction zone
- `player_exited_range()` — emitted when the player leaves the interaction zone

## What it never does
- Does not define what happens on interaction — the Engineer connects interacted to game logic
- Does not modify game state directly
- Does not handle inventory pickup logic internally

## Usage example
Locked door: interactable placed on the door node. The Engineer connects interacted to a function that checks GameState.get_flag("has_key"). If true, it plays the door open animation and disables the collision shape.
