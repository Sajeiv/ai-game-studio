# Seed: ui_element

## What this seed does
Displays a piece of information on the HUD. Can display a text string, a progress bar, an icon, or a numeric counter. Updates automatically when its set_value() method is called, typically wired to a resource seed's value_changed signal or a game_state flag_changed signal. Supports anchor presets for quick HUD positioning.

## Inputs accepted
- `display_type` — TEXT, BAR, ICON, COUNTER (default TEXT)
- `anchor_preset` — TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, CENTER (default TOP_LEFT)
- `label_format` — string with {value} placeholder for TEXT and COUNTER types (default "{value}")
- `icon_texture` — Texture2D resource path, used in ICON mode
- `bar_color` — fill color for BAR type (default green)
- `max_value` — denominator for BAR fill calculation (default 100)

## Outputs and signals
- `display_updated(new_value: Variant)` — emitted whenever set_value() is called

## What it never does
- Does not own the data it displays — it only renders values passed to it
- Does not handle input or interaction
- Does not animate value transitions unless an external tween is wired in

## Usage example
Health bar HUD: ui_element with display_type=BAR, bar_color=green, max_value=100, anchored top-left. The player's resource seed emits value_changed, which the Engineer connects to ui_element.set_value(). At 25% fill, a separate script changes bar_color to red.
