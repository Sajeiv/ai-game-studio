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

### Style consistency

For each game, the Art Director maintains a style prompt prefix extracted from the first reference image or game spec. This prefix is prepended to every generate call:

```
style_prefix: "16-bit pixel art, limited palette, top-down view, dark and moody"
```

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

## Adding a different art service

1. Create `art/<service-name>/adapter.md`
2. Implement the same interface operations listed above
3. Update the `ART_ADAPTER` environment variable to point to the new adapter
4. No other files need to change
