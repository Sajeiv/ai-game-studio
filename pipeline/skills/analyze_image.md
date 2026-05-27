# Skill: analyze_image

## Purpose
Extract style, mood, color palette, and structural information from a reference image.

## Inputs
- `image` — base64-encoded image or file path
- `analysis_type` — one of: `mood | style | palette | character | map`

## Outputs
```json
{
  "mood": "string — overall atmosphere",
  "style": "string — art direction description suitable for PixelLab prompt",
  "palette": ["#hex", "..."],
  "dominant_colors": ["#hex", "..."],
  "notes": "string — anything else relevant to generation"
}
```

## Usage
Called by Director when reference images are provided. Output is merged into the game spec. `style` field is passed directly to PixelLab as a prompt modifier. `palette` is applied to all subsequent asset generation.
