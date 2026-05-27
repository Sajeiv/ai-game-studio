# Seed: dialogue

## What this seed does
Presents lines of text to the player one at a time. Advances on a configurable key press. Supports a typewriter reveal effect, a speaker name field, and branching choices via the dialogue_data array. Pauses the game automatically while active.

## Inputs accepted
- `dialogue_data` — Array of Dictionaries, each with keys: `text` (String), `speaker` (String, optional), `choices` (Array of {text, next_index}, optional)
- `advance_action` — input action name to advance dialogue (default "interact")
- `typewriter_speed` — characters revealed per second; 0 = instant (default 30)
- `auto_pause_game` — whether to set game_state phase to PAUSED while running (default true)

## Outputs and signals
- `dialogue_started()` — emitted when the first line appears
- `line_shown(index: int, text: String)` — emitted each time a line is displayed
- `choice_made(choice_text: String, next_index: int)` — emitted when the player selects a branch
- `dialogue_finished()` — emitted when the last line is shown and dialogue closes

## What it never does
- Does not define story content — all content comes through dialogue_data
- Does not handle shop transactions or inventory exchanges
- Does not trigger scene transitions directly — connect dialogue_finished for that

## Usage example
Quest NPC: interactable seed emits interacted. The Engineer connects this to dialogue.start() with a three-line dialogue_data array ending in a yes/no choice. choice_made signal wires to GameState.set_flag("accepted_quest", true) and scene_manager for a cutscene.
