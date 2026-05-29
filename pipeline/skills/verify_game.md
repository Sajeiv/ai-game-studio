# Skill: verify_game

## Purpose
Self-playtest a generated Godot game before declaring it playtest-ready.
You play through the game yourself, catch every objective error, fix it, and only hand off to the user when the full loop passes cleanly.

## When to run
Always run this skill before saying any build is "playtest ready."
Never skip it. A build that hasn't been self-playtested is not ready.

## How to run (Windows)

```powershell
& "games\{game-title}\tools\run_self_check.ps1"
```

This script:
1. Headless-parses all GDScript (Phase 1)
2. Launches the game window and captures the initial frame (Phase 2)
3. Sends scripted keyboard input to walk the full gameplay loop (Phase 3)
4. Reads the runtime log for errors that only appear during play (Phase 4)
5. Saves numbered screenshots for each key moment
6. Outputs a JSON report and exits 0 (pass) or 1 (fail)

## What to do with the screenshots

After the script finishes, read each screenshot with the `Read` tool (Claude has vision).
Look at each one in sequence and verify the expected game state:

| Screenshot | What to check |
|------------|---------------|
| `01_initial_launch` | World visible (not black), player sprite present, HUD shows "Clues: 0 / 3", camera shows the village |
| `02_mira_dialogue_open` | Dialogue panel open at bottom of screen, Mira's name and first line of text readable |
| `03_after_mira` | Dialogue closed, HUD shows "Clues: 1 / 3" |
| `04_tom_dialogue_open` | Tom's dialogue panel open, text readable |
| `05_after_tom` | HUD shows "Clues: 2 / 3" |
| `06_greta_dialogue_open` | Greta's dialogue open, text readable |
| `07_after_greta` | HUD shows "Clues: 3 / 3" |
| `08_chest_dialogue_open` | Chest opening dialogue visible at bottom of screen |
| `09_win_screen` | Golden background, victory title visible, no error overlay |

## Pass criteria

All of the following must be true:
- Script exits with code 0
- No `SCRIPT ERROR:` in Phase 1 or Phase 4 output
- Screenshots 01–09 all show the expected state described above

## If a check fails

1. Identify which screenshot first shows an unexpected state
2. Read the JSON report for error messages from the log
3. Fix the underlying issue in the relevant script
4. Re-run the self-check from the top — do not declare passing until all 9 screenshots pass

Common failure patterns:

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Screenshot 01 is black | Window launched but renderer crashed | Check Phase 1 parse errors; look for SCRIPT ERROR in Phase 4 log |
| HUD labels invisible / tiny | Font size too small for 1280×720 | Set `add_theme_font_size_override("font_size", 20)` on counter labels |
| Dialogue box is a sliver | `custom_minimum_size` too small | Set to `Vector2(1000, 100)` on the RichTextLabel inside PanelContainer |
| Clue counter not incrementing | Wrong `flag_key` on NPC, or `flag_changed` signal not connected | Verify `flag_key` strings match exactly between NPC and HUD listener |
| Win screen not triggering | `_opening` flag double-trigger guard, or SceneManager path wrong | Verify `SceneManager.go_to("res://scenes/win_screen.tscn")` and that scene exists |
| Player didn't reach NPC | Timing too tight, collision blocking | Increase `duration_ms` on the relevant `hold` step in `run_self_check.ps1` |

## Writing a run_self_check.ps1 for a new game

Every game needs its own `games/{game-title}/tools/run_self_check.ps1` that defines the playthrough steps for that game's specific map layout.

### Step calculation

```
travel_time_ms = ((world_distance_px - interaction_radius_px) / player_speed_pxs) * 1.5 * 1000
```

Default values: `interaction_radius = 48 px`, `player_speed = 80 px/s` (check each game's player.gd override).

Use cardinal movement (one axis at a time). Add `wait` steps between moves for the physics to settle.

### Step types

```powershell
@{ type="hold";       key="down";  duration_ms=2000 }  # hold arrow key for N ms (movement)
@{ type="press";      key="e"                       }  # tap once (interaction, dialogue advance)
@{ type="wait";       duration_ms=600               }  # pause (let animation finish, scene load)
@{ type="screenshot"; label="descriptive_name"      }  # capture + save with vision label
```

### Minimum required screenshots

Every game's playthrough must include:
- `initial_launch` — verify world and HUD rendered correctly
- One screenshot per collectible/clue — verify state tracking works
- `win_screen` or `end_state` — verify the game loop completes

## Mac / Linux equivalents

These equivalents are not yet implemented. Until they are, self-check only runs on Windows.

| Function | Mac | Linux |
|----------|-----|-------|
| Window capture | `screencapture -l <window-id>` | `scrot -u` |
| Key injection | `osascript -e 'tell app "System Events"...'` | `xdotool key` / `xdotool keydown` |
| Log location | `~/Library/Application Support/Godot/...` | `~/.local/share/godot/...` |
