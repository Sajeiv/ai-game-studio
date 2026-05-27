# AI Game Studio

An AI-powered game generation platform. Describe a game in natural language — AI builds it automatically. No game development experience required.

**Talk to AI, get a playable game.**

---

## How it works

1. You describe your game (and optionally drop in reference images)
2. The Director agent turns your description into a structured game spec
3. The Art Director generates pixel art assets in parallel
4. The Engineer assembles the Godot project from the seed library
5. The Validator checks everything and fixes errors automatically
6. You get a playable build — placeholder in under a minute, full art in under 10

---

## Architecture

The pipeline has three layers so that swapping the game engine or art service requires changing only that layer:

```
Layer 1 — Pipeline (engine agnostic)
  pipeline/seeds/     Behavioral descriptions of the 14 universal primitives
  pipeline/agents/    Private — role definitions for each AI agent
  pipeline/skills/    Private — reusable capabilities agents can call

Layer 2 — Engine Adapters
  engines/godot/      Godot 4 implementations of all 14 seeds
  engines/godot/seeds/          14 .gd scripts, one per seed
  engines/godot/builder.md      How to assemble a complete project
  engines/godot/scene_format.md How .tscn files work
  engines/godot/export.md       How to export builds

Layer 3 — Art Adapters
  art/pixellab/       PixelLab API integration
  art/upload/         User-provided sprites
```

---

## The 14 seeds

Seeds are the universal building blocks. Every 2D game mechanic is assembled from combinations of these primitives.

### Tier 1 — Universal (every game)
| Seed | What it does |
|------|-------------|
| `player_controller` | Reads input, moves the player |
| `camera` | Follows a target with configurable smoothing and bounds |
| `scene_manager` | Transitions between scenes with fade/cut/slide |
| `game_state` | Tracks game phase and named flags, emits signals |

### Tier 2 — Very common (most games)
| Seed | What it does |
|------|-------------|
| `autonomous_mover` | Moves without player input — patrol, chase, or wander |
| `interactable` | Shows a prompt, fires a signal when the player interacts |
| `resource` | Tracks a clamped numeric value — health, ammo, score |
| `audio_manager` | Plays SFX and music, controls bus volumes |
| `ui_element` | Displays a value as text, a bar, or an icon on the HUD |

### Tier 3 — Common (many games)
| Seed | What it does |
|------|-------------|
| `detector` | Senses targets by area overlap or proximity |
| `spawner` | Creates instances on a timer or on demand |
| `projectile` | Travels in a direction, emits hit signal on collision |
| `dialogue` | Presents text lines with typewriter effect |
| `timer_event` | Fires a signal after a configurable delay |

---

## Mechanics from seeds

Any game mechanic is a combination of seeds wired together:

| Mechanic | Seeds |
|----------|-------|
| Monster that chases player | `autonomous_mover` + `detector` |
| Locked door | `interactable` + `game_state` + `scene_manager` |
| Shop NPC | `interactable` + `dialogue` + `resource` |
| Bullet hell boss | `autonomous_mover` + `spawner` + `projectile` + `timer_event` + `resource` |
| Collectible coin | `interactable` + `resource` + `audio_manager` |
| Checkpoint | `detector` + `game_state` + `scene_manager` |
| Turret | `detector` + `projectile` + `timer_event` |

---

## Repository layout

```
pipeline/
  seeds/
    tier1/          player_controller, camera, scene_manager, game_state
    tier2/          autonomous_mover, interactable, resource, audio_manager, ui_element
    tier3/          detector, spawner, projectile, dialogue, timer_event
  agents/           Private — agent role definitions
  skills/           Private — agent skill specifications

engines/
  godot/
    seeds/          14 Godot 4 GDScript implementations
    builder.md      How to assemble a Godot project
    scene_format.md .tscn file reference
    export.md       How to export web and desktop builds

art/
  pixellab/
    adapter.md      PixelLab API integration spec
  upload/
    adapter.md      User upload handler spec

presets/            Ready-made game specs (horror_escape, rpg, …)

tools/
  pixellab-mcp/     Node.js MCP server — calls PixelLab, saves assets locally
  setup/            First-run setup scripts

games/              Generated game projects (gitignored)

.github/
  workflows/        CI checks for community seed submissions
```

---

## Quick start

```bash
git clone <repo>
cd ai-game-studio
tools\setup\setup.bat      # Windows
# or: bash tools/setup/setup.sh
```

Copy `.env.example` to `.env` and fill in your API keys, then open Claude Code and describe your game.

---

## Presets

Pass a preset name to the Director to skip the spec-building step.

| Preset | Description |
|--------|-------------|
| `horror_escape` | Top-down horror, no combat, chaser enemy, key/door puzzle |
| `rpg` | Top-down RPG, turn-based combat, dialogue, save/load |

---

## Contributing

Community can contribute:
- New seed implementations for existing engines (`engines/`)
- New engine adapters (new folder under `engines/`)
- New art adapters (new folder under `art/`)
- Bug fixes to existing seeds

Community cannot submit changes to `pipeline/seeds/` (seed descriptions are maintained by the core team) or to agent/skill prompts (those are private).

### Submitting a seed implementation

1. Add your `.gd` file to `engines/godot/seeds/`
2. Include the documentation header:
   ```
   # SEED: <name>
   # STATUS: placeholder
   # DESCRIPTION: ...
   # EXPORTS: ...
   # SIGNALS: ...
   ```
3. Keep it under 50 lines, no dependencies on other seeds
4. Open a PR — automated checks run on push:
   - GDScript syntax valid
   - No `OS.execute()` calls
   - No file system access outside `res://` or `user://`
   - No HTTP requests
   - No naming conflicts with existing seeds
   - Documentation header present

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

**Public (this repo):** seed descriptions, engine implementations, art adapters, tools, presets, CI workflows  
**Private:** agent system prompts, pipeline orchestration, skills implementation, hosted backend

The seeds and engines are the community hook. The pipeline intelligence is the moat.

---

## License

MIT
