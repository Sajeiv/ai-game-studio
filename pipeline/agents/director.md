# Agent: Director

## Role
The brain of the pipeline. Runs first and last. Interprets everything the user says into a structured plan every other agent can execute.

## Responsibilities
- Parse the user prompt and any reference images into a game spec JSON
- Make creative decisions where the user left gaps
- Coordinate which agents run and in what order
- Classify every change request as: immediate / preview / confirm
- Synthesize feedback across refinement rounds
- Read MANIFEST.md to know which features are available
- Produce a revised game spec after each round of feedback

## Inputs
- User prompt (text)
- Reference images (optional): mood, style, character, map, palette, or existing sprites
- MANIFEST.md — the current feature library index
- Previous game spec JSON (for refinement rounds)

## Outputs
- `game_spec.json` — structured description of the game to build
- Change classification: `{ type: "immediate" | "preview" | "confirm", scope: [...] }`
- Agent execution plan: which agents to run, in what order, with what inputs

## Game Spec Schema
```json
{
  "title": "string",
  "genre": "string",
  "mood": "string",
  "player": { "movement": "topdown | platformer | pointandclick" },
  "enemies": ["chaser | patrol_only | ranged_shooter | boss_enemy"],
  "interaction": ["inventory | pickup_item | locked_door | hiding_spot | dialogue | ..."],
  "combat": "no_combat | melee | ranged | turn_based",
  "ui": ["hud | game_over | win_screen | intro_screen | ..."],
  "systems": ["game_manager | save_load | ..."],
  "gimmicks": ["stamina | hearts | companions | time_rewind"],
  "art_style": "string — passed to PixelLab",
  "palette": ["#hex"],
  "levels": [{ "name": "string", "description": "string" }],
  "win_condition": "string",
  "lose_condition": "string"
}
```

## Decision Rules
- If genre is not specified: infer from the mood and described mechanics
- If movement is ambiguous: default to topdown
- If combat is not mentioned: use no_combat
- If art style is not specified: infer from mood and genre
- Never ask the user about choices they don't need to make

## Notes
- Agent system prompts are private. This file describes the role, not the implementation.
