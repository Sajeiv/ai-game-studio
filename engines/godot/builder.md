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
window/size/viewport_width=1280
window/size/viewport_height=720

[rendering]
textures/canvas_textures/default_texture_filter=0
```

**Never set `window/stretch/mode` or `window/stretch/aspect`** — these shrink the effective world space and cause HUD elements to appear at wrong sizes. Let Godot default to no stretching.

### Viewport size rules

| Game type | Viewport | Reason |
|-----------|----------|--------|
| Top-down / RPG / puzzle | 1280 × 720 | Standard HD; Camera2D zoom handles visible area |
| Pixel art (explicit low-res look) | 320 × 180 + stretch canvas_items | Only when pixel art look is the deliberate art direction |

Default to **1280 × 720** unless the game spec explicitly calls for a low-res pixel art aesthetic.

### Camera zoom rules

Camera zoom = world pixels visible per screen pixel. **Higher zoom = fewer world pixels visible (zoomed in).**

| Goal | zoom value |
|------|-----------|
| See the entire 960 × 640 world in a 1280 × 720 viewport | `Vector2(0.75, 0.75)` |
| Typical top-down RPG (see ~850 × 480 of world) | `Vector2(1.5, 1.5)` |
| Tight follow camera (see ~640 × 360 of world) | `Vector2(2.0, 2.0)` |

Formula: `visible_world_width = viewport_width / zoom_x`

For a 960 × 640 world with 1280 × 720 viewport:
- zoom=1.5 → player sees ~853 × 480 (world partially off-screen — player must explore)
- zoom=0.75 → entire world fits on screen at once

### HUD sizing rules (1280 × 720 viewport)

| Element | Minimum size | Font size |
|---------|-------------|-----------|
| Dialogue box label | `Vector2(1000, 100)` | default (scales with box) |
| HUD counter / score | N/A | 20 |
| Intro / hint text | N/A | 14–16 |
| Win screen title | N/A | 48+ |

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

---

## Grid-based push mechanics (Sokoban / puzzle)

Use **`StaticBody2D` + programmatic `position =`**, not `RigidBody2D`, for pushable objects in grid-based puzzle games.

### Why not RigidBody2D

Setting `position` directly on a `RigidBody2D` conflicts with its physics simulation. The PhysicsServer still holds the body at the old position until the next physics tick, so the visual teleports while the collision stays behind — producing a visible ghost at the previous tile.

### Correct pattern

```gdscript
# Pushable object node type
[node name="Relic1" type="StaticBody2D" groups=["relic"]]

# Move it by setting position directly in a glue script
relic.position = Vector2(col * TILE_SIZE + TILE_SIZE / 2.0, row * TILE_SIZE + TILE_SIZE / 2.0)
```

The glue script (`_physics_process`) reads input direction, computes the destination tile, checks a wall-set Dictionary for blockers, then sets `position`. No physics forces involved.

### Seal / pressure-plate detection

Do **not** rely on `body_entered` / `body_exited` signals from Area2D when objects are moved by `position =`. `StaticBody2D` moved this way does not reliably fire those signals. Instead, after every push, compare tile coordinates directly:

```gdscript
func _update_plate_states() -> void:
    for plate in plates:
        var plate_tile := _world_to_tile(plate.position)
        if _relic_grid.has(plate_tile):
            _activate_plate(plate)
        else:
            _deactivate_plate(plate)
```

Keep a `_relic_grid: Dictionary` (Vector2i → Node2D) as the authoritative source of relic positions. Update it on every push before calling `_update_plate_states()`.

---

## Platformer genre — player physics

The `player_controller` seed handles top-down movement. For a platformer, extend it and override `_physics_process` to add gravity, coyote time, and a jump buffer.

### Required exports

```gdscript
@export var jump_force: float = -480.0
@export var gravity:    float = 900.0
```

### Coyote time + jump buffer

```gdscript
const COYOTE_TIME := 0.1   # stays jumpable briefly after walking off a ledge
const JUMP_BUFFER := 0.1   # remembers a jump press briefly before landing

var _coyote_timer:      float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor:      bool  = false

func _physics_process(delta: float) -> void:
    var on_floor := is_on_floor()

    if on_floor:
        _coyote_timer = COYOTE_TIME
    else:
        _coyote_timer = maxf(_coyote_timer - delta, 0.0)

    if Input.is_action_just_pressed("ui_accept"):
        _jump_buffer_timer = JUMP_BUFFER
    else:
        _jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

    if not on_floor:
        velocity.y += gravity * delta

    if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
        velocity.y = jump_force
        _coyote_timer = 0.0
        _jump_buffer_timer = 0.0

    velocity.x = Input.get_axis(input_left, input_right) * speed
    move_and_slide()
    _update_anim()
```

### Platformer animations

Platformer uses `idle`, `run`, `jump` + `flip_h` — not 4-directional walk animations:

```gdscript
func _update_anim() -> void:
    var anim := "idle"
    if not is_on_floor():
        anim = "jump"
    elif absf(velocity.x) > 1.0:
        anim = "run"
    if anim != _last_anim:
        _last_anim = anim
        _body.play(anim)
    if velocity.x != 0.0:
        _body.flip_h = velocity.x < 0.0
```

Required SpriteFrames animations: `idle` (1 frame, no loop), `run` (4 frames, loop), `jump` (1 frame, no loop).

---

## Platformer genre — enemy patrol with gravity

The `autonomous_mover` seed does not simulate gravity. For a platformer enemy, extend it and completely override `_physics_process`.

### Gravity + patrol bounds

```gdscript
@export var gravity:           float = 900.0
@export var patrol_half_range: float = 96.0

var _patrol_min_x: float
var _patrol_max_x: float

func _ready() -> void:
    super._ready()
    # Capture bounds as fixed world-space values at spawn time.
    # Do NOT use to_global(waypoints[i]) for patrol bounds —
    # it recalculates relative to current position each frame,
    # so the target always moves with the enemy and is never reached.
    _patrol_min_x = global_position.x - patrol_half_range
    _patrol_max_x = global_position.x + patrol_half_range
    _set_dir(Vector2.RIGHT)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += gravity * delta
    else:
        velocity.y = 0.0

    if global_position.x <= _patrol_min_x:
        _set_dir(Vector2.RIGHT)
    elif global_position.x >= _patrol_max_x:
        _set_dir(Vector2.LEFT)

    velocity.x = _dir.x * speed
    move_and_slide()

    # Reverse on wall collision (covers unexpected obstacles mid-patrol)
    for i in get_slide_collision_count():
        if absf(get_slide_collision(i).get_normal().x) > 0.5:
            _set_dir(Vector2(-_dir.x, 0.0))
            break

    _sprite.flip_h = _dir.x < 0.0
```

---

## Platformer genre — TileMap rules

### Layer structure

Platformers use a **single TileMap layer** with two tile sources:

| Source ID | Tile | Collision |
|-----------|------|-----------|
| 0 | Ground / floor tiles | Full-tile polygon |
| 1 | Floating platform tiles | Full-tile polygon |

Unlike top-down maps, both sources are solid — there is no ground-without-collision layer.

### TileSet setup order

Same rule as top-down: register the source **before** calling `get_tile_data()`:

```gdscript
src.create_tile(Vector2i(0, 0))
ts.add_source(src, SOURCE_ID)             # register first
var td := src.get_tile_data(Vector2i(0, 0), 0)
td.add_collision_polygon(0)               # then configure collision
td.set_collision_polygon_points(0, 0, col_poly)
```

### Camera for wide platformer levels

Wide levels (100+ tiles) should set `use_bounds = true` on the camera seed so the view clamps to world edges and never shows the empty void beyond the level.

---

## Dialogue + interactable — input conflict

The `dialogue` seed's `_unhandled_input` must call `get_viewport().set_input_as_handled()` after it processes the advance key. Without this, the same keypress that advances the dialogue also fires every in-range `interactable`'s `interacted` signal simultaneously, which calls `$Dialogue.start()` again and resets the dialogue to line 0. The player can never advance past the first line while standing near an object.

The fix is already in `engines/godot/seeds/dialogue.gd`. Any copy of dialogue.gd in a game's `seeds/` folder must include it:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return
    if not event.is_action_pressed(advance_action):
        return
    get_viewport().set_input_as_handled()   # ← required
    ...
```

---

## Dialogue + CONNECT_ONE_SHOT — already-connected guard

When a room glue script connects `dialogue_finished` with `CONNECT_ONE_SHOT` inside an `interacted` handler, the connection is only removed after the signal actually fires (i.e., after the player reads to the last line). If the player opens the dialogue, closes it early (scene transition, other means), and then opens it again, the second `connect()` call throws:

```
ERROR: Signal 'dialogue_finished' is already connected to given callable
```

Guard every CONNECT_ONE_SHOT connection:

```gdscript
func _on_working_terminal(_i: Node) -> void:
    $Dialogue.start(WORKING_TERMINAL_LINES)
    if not $Dialogue.dialogue_finished.is_connected(_on_code_revealed):
        $Dialogue.dialogue_finished.connect(_on_code_revealed, CONNECT_ONE_SHOT)
```

---

## Top-down genre — door row boundary

Leaving a door tile as a floor tile (no wall) in the perimeter creates a gap the player can walk through and off the map. The TileMap has no content beyond its defined tile range, so the player exits the playable area with no collision to stop them.

Two safe approaches:

**Option A — interactable one tile inward.** Place the door interactable at tile `(COLS-2, row)` (one tile inside the wall), not at the perimeter. The wall tile at `(COLS-1, row)` remains solid and stops the player. The 48px interaction radius covers the gap.

**Option B — StaticBody2D barrier at the edge.** Keep the door tile as floor but add a thin `StaticBody2D` at x = `COLS * TILE_SIZE` covering the full column height except the door row. This is the same world-boundary pattern used in top-down maps alongside TileMap walls.
