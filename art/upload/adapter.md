# Art Adapter — User Upload

How the Art Director handles user-provided sprites, bypassing generation entirely.

---

## Overview

When the user supplies their own art, the pipeline skips PixelLab and uses the uploaded assets directly. This adapter handles accepting, validating, and placing those assets in the correct locations.

---

## Interface

Implements the same interface as all art adapters:

| Operation | Behavior |
|-----------|----------|
| `generate(prompt, style_ref, width, height)` | Not supported — returns null, falls back to placeholder |
| `generate_sprite_sheet(...)` | Not supported — returns null |
| `generate_tileset(...)` | Not supported — returns null |
| `download(url, destination_path)` | Copies a local file path to the destination |
| `extract_palette(image_path)` | Reads the image and returns dominant hex colors |

---

## Accepted formats

- PNG (preferred)
- JPG (no transparency, avoid for sprites)
- WebP

Recommended sprite sizes: 8×8, 16×16, 32×32, 48×48, 64×64 pixels.

---

## How to supply assets

The user places their files in the session's upload directory. The Art Director then maps them to the asset slots defined in the game spec:

```
upload/
  player.png       <- maps to player character sprite
  enemy.png        <- maps to primary enemy sprite
  tiles.png        <- maps to ground tileset
  item_key.png     <- maps to key item
```

The mapping is declared in the game spec under `art.uploads`:

```json
"art": {
  "uploads": {
    "player": "upload/player.png",
    "enemy": "upload/enemy.png",
    "tileset_ground": "upload/tiles.png",
    "item_key": "upload/item_key.png"
  }
}
```

---

## Validation

Before copying, the adapter checks:
- File exists and is readable
- Format is PNG, JPG, or WebP
- Dimensions are power-of-two or match expected size

If a file fails validation, a solid-color placeholder is used and the Art Director notes which slot needs a valid upload.

---

## Palette extraction

Even when using uploaded art, the adapter extracts the dominant palette so the Art Director can generate any missing assets (UI elements, effects) in a consistent style:

```
extract_palette("upload/player.png")
→ ["#1a1a2e", "#16213e", "#0f3460", "#e94560"]
```

---

## Partial upload

Users can supply some assets and let PixelLab generate the rest. In that case, the pipeline uses the upload adapter for provided slots and falls through to the PixelLab adapter for missing ones. The extracted palette from uploaded art is passed as a style reference to PixelLab to maintain visual consistency.
