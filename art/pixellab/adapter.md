# Art Adapter — PixelLab

How the Art Director generates and downloads pixel art assets via PixelLab.

---

## Overview

PixelLab is the current art generation service. The Art Director never calls PixelLab directly — it always goes through this adapter interface. Swapping to a different service means replacing this file and its implementation, nothing else.

---

## Interface

Every art adapter must implement these operations:

| Operation | Description |
|-----------|-------------|
| `generate(prompt, style_ref, width, height)` | Generate a single image and return its URL |
| `generate_sprite_sheet(prompt, style_ref, frame_count, frame_size)` | Generate an animated sprite sheet |
| `generate_tileset(prompt, style_ref, tile_size, tile_count)` | Generate a tileset |
| `download(url, destination_path)` | Download an asset to a local path |
| `extract_palette(image_path)` | Return the dominant color palette as an array of hex strings |

---

## PixelLab implementation

> **Docs:** Always include `@ https://api.pixellab.ai/mcp/docs` in Art Director prompts so the agent has access to the current API specification.

### Authentication

The `PIXELLAB_API_KEY` environment variable must be set. Never hardcode it.

### MCP server

Assets are downloaded via the `pixellab-godot` MCP server at `tools/pixellab-mcp/`. The Art Director calls the MCP tool `download_asset` which handles the PixelLab API call and saves the file locally.

```
tool: download_asset
args:
  prompt: "top-down player character, 16x16 pixels, dark fantasy style"
  style_reference_url: "<url from reference image analysis>"
  width: 16
  height: 16
  destination: "res://assets/sprites/player.png"
```

### Items and props

All item and prop sprites (keys, chests, furniture, pickups, interactive objects) must use `create_map_object` instead of `generate`. This endpoint supports transparent backgrounds natively and applies style matching from a reference image automatically.

**Via MCP tool** (preferred — supports style reference):
```
tool: create_map_object
args:
  description: "{style_prefix}, key item, top-down view"
  image_size: { width: 32, height: 32 }
  style_image: "<base64 of generated tileset>"
```

**Via REST API** (fallback — no style_image param):
```
POST /v2/map-objects
{ "description": "{style_prefix}, key item, top-down view", "image_size": { "width": 32, "height": 32 } }
```
Poll `GET /v2/background-jobs/{background_job_id}` every 5 s until `status === "completed"`, then read `last_response.image` (plain base64, no data-URI prefix).

Using `create_map_object` for non-tile assets ensures:
- Transparent background without post-processing (always on, no flag needed)
- Visual consistency with the tileset when `style_image` is passed via MCP
- Correct depth and perspective for top-down placement

### Transparent backgrounds

Every sprite prompt must explicitly include `transparent background`. This applies to every `generate`, `generate_sprite_sheet`, and `create_map_object` call. Never generate sprites with solid or white backgrounds.

### Style consistency

For each game, the Art Director maintains a style prompt prefix extracted from the first reference image or game spec. This prefix is **identical across every generate call in the game** — characters, items, props, tilesets, UI elements. Never use a different style prefix for different asset types in the same game.

```
style_prefix: "16-bit pixel art, limited palette, top-down view, dark and moody"
```

**Tileset-as-reference rule:** When generating any non-tile asset (characters, items, props, UI), pass the generated tileset image URL as `style_reference_url`. This is the strongest single tool for visual consistency across a game. Generate the tileset first — all other assets follow from it.

### Sprite sheets

PixelLab generates individual frames. The MCP server stitches them into a horizontal sprite sheet:

```
tool: download_sprite_sheet
args:
  prompts: ["idle frame 1", "idle frame 2", "walk frame 1", "walk frame 2"]
  style_prefix: "<style_prefix>"
  frame_width: 16
  frame_height: 16
  destination: "res://assets/sprites/player_sheet.png"
```

### Refinement

All generation attempts are kept in `assets/sprites/history/`. The Art Director never overwrites a previous attempt — it appends a version suffix (`_v2`, `_v3`). The user always sees all versions and picks the one to apply.

---

## Error handling

If a PixelLab call fails, the Art Director silently retries once with a simplified prompt. If the retry fails, it generates a solid-color placeholder sprite at the correct dimensions. The user never sees an error — they see a placeholder with a note that art generation is pending.

---

## Top-down character animation requirements

### Minimum frame set

Every top-down playable character must ship with:

| Animation | Frames | Loop |
|-----------|--------|------|
| `idle` | 1 (base sprite) | false |
| `walk_down` | 4 | true |
| `walk_up` | 4 | true |
| `walk_left` | 4 | true |
| `walk_right` | 4 | true |

Total: 17 assets per character (1 idle + 16 walk frames).

### File naming convention

```
assets/sprites/player.png               ← idle (base sprite)
assets/sprites/player/walk_down_1.png
assets/sprites/player/walk_down_2.png
assets/sprites/player/walk_down_3.png
assets/sprites/player/walk_down_4.png
assets/sprites/player/walk_up_1..4.png
assets/sprites/player/walk_left_1..4.png
assets/sprites/player/walk_right_1..4.png
```

### Prompt structure per frame

Use a consistent style prefix across all frames so they read as the same character:

```
{style_prefix}, character facing {direction}, {foot_position}, walk cycle frame {n} of 4
```

Direction descriptions:
- `walk_down` — "facing south toward camera"
- `walk_up` — "facing north, back to camera"
- `walk_left` — "side profile facing left"
- `walk_right` — "side profile facing right"

Foot positions cycle: right foot forward → feet neutral → left foot forward → feet neutral

### Size constraint

PixelLab API minimum canvas is 32×32. All character sprites must be 32×32 or larger.
16×16 characters are not supported — generate at 32×32 and scale in the engine if needed.

### Generation order

Generate all frames with `Promise.allSettled()` in batches of 4 (one direction per batch) to stay within API rate limits while parallelising within each direction.

---

## Adding a different art service

1. Create `art/<service-name>/adapter.md`
2. Implement the same interface operations listed above
3. Update the `ART_ADAPTER` environment variable to point to the new adapter
4. No other files need to change
