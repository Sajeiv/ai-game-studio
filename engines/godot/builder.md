# Godot 4 — Builder

How to assemble a complete Godot 4 project from seeds.

---

## Project structure

```
res://
  project.godot         <- project settings, autoloads, input map
  scenes/
    main.tscn           <- entry point scene
    levels/             <- level scenes
    ui/                 <- HUD and screen scenes
  scripts/              <- any game-specific glue scripts
  assets/
    sprites/            <- generated sprite sheets
    audio/              <- music and SFX
    fonts/              <- UI fonts
  seeds/                <- copies of the seeds used in this project
```

---

## Step 1 — Configure project.godot

Set the main scene, window size, and pixel art settings:

```
[display]
window/size/viewport_width=320
window/size/viewport_height=180
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[rendering]
textures/canvas_textures/default_texture_filter=0
```

Register autoload singletons:

```
[autoload]
GameState="*res://seeds/game_state.gd"
SceneManager="*res://seeds/scene_manager.gd"
AudioManager="*res://seeds/audio_manager.gd"
```

Register input actions for player interaction and movement:

```
[input]
interact={ "events": [InputEventKey key=69] }   # E key
ui_left / ui_right / ui_up / ui_down            # use defaults
```

---

## Step 2 — Copy seeds into the project

Copy only the seeds required by the game spec from `engines/godot/seeds/` into `res://seeds/`. Do not copy seeds that are not used.

---

## Step 3 — Build the main scene

Create `scenes/main.tscn`. Add:
- A Node2D as root
- Player node using `player_controller.gd`
- Camera node using `camera.gd`, target_path pointing to the player
- TileMapLayer node for the level ground

---

## Step 4 — Wire seeds together

Seeds emit signals — they do not call each other directly. The Engineer writes a small glue script on the scene root that connects signals across seeds:

```gdscript
func _ready() -> void:
    $Player/Health.depleted.connect(_on_player_died)
    $Enemy/Detector.target_detected.connect(_on_enemy_sees_player)

func _on_player_died() -> void:
    GameState.phase = GameState.GamePhase.LOSE

func _on_enemy_sees_player(target) -> void:
    $Enemy/Mover.mode = $Enemy/Mover.Mode.CHASE
    $Enemy/Mover._target = target
```

---

## Step 5 — Add levels

Each level is its own scene. Use scene_manager.go_to() to transition between them. Pass data (level index, score) via the payload dictionary.

---

## Step 6 — Validate before handing off

Run the Validator agent. It checks every scene and script for errors and fixes them silently. The project is ready when the Validator reports clean.

---

## Top-down genre — TileMap rules

### Layer structure (mandatory)

Every top-down map must have exactly two TileMap layers, built in this order:

| Index | Name | Tile | Collision |
|-------|------|------|-----------|
| 0 | Ground | `ground_tile.png` | None |
| 1 | Walls / Trees | `tree.png` or wall tile | Full-tile polygon |

Never use a single layer for both ground and obstacles.

### TileSet setup order (critical)

The collision polygon must be registered **after** the source is added to the TileSet. The wrong order silently discards the polygon:

```gdscript
# WRONG — add_collision_polygon no-ops, TileData has no physics layer reference
ts_src.create_tile(Vector2i(0, 0))
var td := ts_src.get_tile_data(Vector2i(0, 0), 0)
td.add_collision_polygon(0)           # silently ignored
ts.add_source(ts_src, 1)

# CORRECT — source registered first, TileData can resolve physics layer 0
ts_src.create_tile(Vector2i(0, 0))
ts.add_source(ts_src, 1)              # register before touching TileData
var td := ts_src.get_tile_data(Vector2i(0, 0), 0)
td.add_collision_polygon(0)           # works
td.set_collision_polygon_points(0, 0, PackedVector2Array([
    Vector2(-16, -16), Vector2(16, -16),
    Vector2(16, 16),   Vector2(-16, 16),
]))
```

### Collision layer settings

```gdscript
ts.add_physics_layer(0)
ts.set_physics_layer_collision_layer(0, 1)  # wall tiles live on layer 1
ts.set_physics_layer_collision_mask(0, 1)   # they see layer 1
```

Player `CharacterBody2D` uses Godot defaults (`collision_layer = 1`, `collision_mask = 1`), so no extra config is needed on the player side.

### Map design rules

- Always leave a clear path to every key / objective — use `_clear_radius()` around item positions
- Gate / exit opening must match exactly: gate pixel position ÷ tile size = tile columns to leave clear
- World boundary `StaticBody2D` walls (left, right, bottom) are kept alongside the TileMap — they are the hard fallback if tile collision is ever reconfigured
- Generate the tile mask from a `PackedByteArray` (`ROWS × COLS`) and iterate once to call `set_cell()` — avoids nested array allocation
