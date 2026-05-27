# Seed: scene_manager

## What this seed does
Handles loading and transitioning between scenes. Supports fade, cut, and slide transitions. Can pass a data dictionary payload to the incoming scene. Registers as an autoload singleton so any scene can call it without a direct reference.

## Inputs accepted
- `transition_type` — FADE, CUT, SLIDE_LEFT, SLIDE_RIGHT (default FADE)
- `transition_duration` — seconds for the transition animation (default 0.4)
- `scene_path` — resource path string, provided at call time not as an export

## Outputs and signals
- `transition_started(to_scene: String)` — emitted when a transition begins
- `transition_finished(to_scene: String)` — emitted when the new scene is fully loaded and visible
- `scene_loaded(scene_name: String)` — emitted after the incoming scene's ready() completes

## What it never does
- Does not decide when to change scenes — that is game_state's responsibility
- Does not persist data across scenes — use game_state for cross-scene data
- Does not manage loading screens for large scenes

## Usage example
Dungeon crawler: game_state emits game_won(). The Engineer connects that signal to SceneManager.go_to("res://scenes/win_screen.tscn") with transition_type=FADE and duration=0.6.
