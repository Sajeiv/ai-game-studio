# AI Game Studio

An AI-powered game generation platform. Describe a game in natural language — AI builds it automatically in Godot 4. No game development experience required.

**Talk to AI, get a playable game.**

---

## How it works

1. You describe your game (and optionally drop in reference images)
2. The Director agent turns your description into a structured game spec
3. The Art Director generates pixel art assets via PixelLab in parallel
4. The Engineer assembles the Godot project from the feature library
5. The Validator checks everything and fixes errors automatically
6. You get a playable build — placeholder in under a minute, full art in under 10

---

## Repository layout

```
features/        Reusable GDScript modules — the building blocks
  player/        Movement systems
  enemies/       Enemy behaviours
  interaction/   Inventory, pickups, doors, dialogue, hiding spots
  combat/        Combat systems (including no_combat)
  ui/            HUD, screens, dialogue box, inventory UI
  systems/       Game manager, save/load, transitions, camera
  gimmicks/      Stamina, hearts, companions, time rewind
  submitted/     Community PRs awaiting review

presets/         Ready-made feature combinations (horror_escape, rpg, …)

pipeline/
  agents/        Role definitions for each AI agent
  skills/        Reusable skill specifications

tools/
  pixellab-mcp/  MCP server — calls PixelLab API, saves assets locally
  setup/         First-run setup scripts

games/           Generated game projects (gitignored)
.github/
  workflows/     CI checks for community module submissions
```

---

## Quick start

```bash
git clone <repo>
cd ai-game-studio
tools\setup\setup.bat      # Windows
# or on Mac/Linux: bash tools/setup/setup.sh
```

Fill in `.env` with your API keys (copied from `.env.example`), then open Claude Code and start the pipeline.

---

## Feature library

Every file in `features/` is a self-contained GDScript module with a documentation header:

```
# FEATURE: topdown_movement
# STATUS: verified | placeholder
# DESCRIPTION: ...
# INPUTS: ...
# EXPORTS: ...
# DEPENDENCIES: ...
```

**verified** — tested in a working game, safe to use  
**placeholder** — correct structure, awaiting real-world testing

---

## Presets

`presets/` contains ready-made feature combinations. Pass a preset name to the Director to skip the spec-building step.

| Preset | Description |
|--------|-------------|
| `horror_escape` | Top-down horror, no combat, chaser enemy, key/door puzzle |
| `rpg` | Top-down RPG, turn-based combat, dialogue, save/load |

---

## Contributing a module

1. Add your `.gd` file to `features/submitted/`
2. Include the documentation header (see format above)
3. Open a PR — automated checks run on push:
   - GDScript syntax valid
   - No `OS.execute()` calls
   - No `FileAccess` outside `res://` or `user://`
   - No HTTP requests
   - No naming conflicts with verified modules
   - Documentation header present

Modules that pass all checks are reviewed by a maintainer before moving to `features/verified/`.

---

## Tech stack

- **Godot 4** — game engine
- **PixelLab** — AI pixel art generation
- **Claude** — orchestrates the entire pipeline
- **pixellab-godot MCP** — Node.js MCP server, bridges Claude to PixelLab
- **Node.js** — runs MCP servers

---

## Environment variables

See `.env.example` for all required variables. Never commit `.env`.

---

## What's public / what's private

**Public (this repo):** feature library, presets, tools, docs, CI workflows  
**Private:** agent system prompts, pipeline orchestration logic, skills implementation, hosted backend

The features are the community hook. The pipeline is the moat.

---

## License

MIT
