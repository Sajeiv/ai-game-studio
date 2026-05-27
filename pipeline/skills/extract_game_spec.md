# Skill: extract_game_spec

## Purpose
Convert a natural language game description into a structured game spec JSON.

## Inputs
- `prompt` — raw user text
- `image_analysis` — output from analyze_image (optional)
- `previous_spec` — existing game spec for refinement rounds (optional)

## Outputs
A complete `game_spec.json` conforming to the schema defined in `pipeline/agents/director.md`.

## Rules
- Fill every field — never leave required fields null
- Apply smart defaults for anything the user did not specify
- On refinement rounds, only update fields the user's feedback touches; preserve everything else
- If the prompt is ambiguous, make a creative decision and note it in `notes`
