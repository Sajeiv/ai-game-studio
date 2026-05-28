# AI Game Studio — Project Context

## Vision
An AI-powered game generation platform. Users describe a game in natural
language, AI builds it automatically. Think RPG Maker but fully AI driven.
No game development experience required.

## Core Promise
Talk to AI, get a playable game.

## Design Principles
- Seed-based not feature-based — 14 universal primitives cover all 2D games
- Engine-agnostic — seeds are behavioral descriptions, implementations are separate
- Art-agnostic — art generation is pluggable, PixelLab is just one adapter
- Surgical edits not full regeneration
- Parallel generation wherever possible
- Instant placeholder builds — playable in under a minute
- Silent error handling — users never see errors, validator fixes silently
- Smart defaults — only pause for approval when it matters
- Progressive onboarding — ask for accounts only when needed
- Privacy first — no hardcoded paths or API keys ever

---

## Tech Stack
- Godot 4 — current game engine (plain text files, exports everywhere, free)
- PixelLab API — current art generation service
- Claude Code — orchestrates the entire pipeline
- PixelLab MCP (native) — official HTTP MCP server, no local install required
- Node.js — runs any custom MCP servers

## Setup

Add the native PixelLab MCP to Claude Code:

```
claude mcp add pixellab https://api.pixellab.ai/mcp -t http -H "Authorization: Bearer YOUR_KEY"
```

Replace `YOUR_KEY` with the value of `PIXELLAB_API_KEY` from your `.env` file.
This gives the Art Director direct access to the PixelLab API docs and tools.

---

## Architecture Overview

The pipeline is split into three layers:

```
Layer 1 — Pipeline (engine agnostic)
  Agents, skills, seed descriptions
  Knows HOW to build any game
  Never mentions Godot or PixelLab directly

Layer 2 — Engine Adapters
  Engine-specific implementations of seeds
  Currently: Godot 4
  Future: Unity, web, others

Layer 3 — Art Adapters
  Art service integrations
  Currently: PixelLab, user upload
  Future: other generators
```

Swapping engines = swap the engine adapter, nothing else changes
Swapping art services = swap the art adapter, nothing else changes

---

## Agent System

### Agent 1 — Director
The brain. Runs first, runs last, supervises everything.
- Interprets user prompt and reference images
- Produces structured game spec JSON
- Makes creative decisions when user does not specify
- Coordinates which agents run and in what order
- Classifies change requests (immediate / preview / confirm)
- Synthesizes feedback across refinement rounds
- Reads seed descriptions to know what is available

### Agent 2 — Art Director
Everything visual.
- Generates sprites, tilesets, items, UI art via art adapter
- Maintains visual consistency across all assets
- Manages refinement history (all attempts kept)
- Extracts color palette from reference images
- Downloads all assets via pixellab-godot MCP
- Never hardcodes PixelLab — always goes through art adapter

### Agent 3 — Engineer
Everything technical.
- Reads seed descriptions from pipeline/seeds/
- Picks correct engine adapter (currently Godot)
- Uses engine seeds as starting point, never generates from scratch
- Combines seeds to build mechanics
- Writes all scene files and project config
- Handles surgical edits — changes only what is needed

### Agent 4 — Validator
The safety net. Always runs silently before user sees anything.
- Reads every generated file
- Fixes errors automatically — never reports them to user
- If a file cannot be fixed, silently regenerates it from seed
- Loops until everything is clean
- User only ever sees: generating / ready

### Agent 5 — Producer
The orchestrator.
- Decides what to show user and when
- Manages approval gates
- Tracks art generation budget
- Maintains conversation history
- Coordinates parallel vs sequential execution
- Knows when to interrupt with preview vs proceed silently

---

## Skills Library
Reusable capabilities any agent can call:

- analyze_image — extract style, mood, palette from reference images
- extract_game_spec — turn natural language into structured JSON
- classify_change — immediate vs preview vs confirm
- read_project — parse existing project structure
- generate_scene — write valid engine scene files
- validate_code — check generated code for errors
- surgical_edit — modify specific files without touching others
- export_build — trigger engine export to web or desktop
- write_game_page — generate title, description, cover art prompt

---

## Seed System

### What seeds are
14 universal behavioral primitives that cover every 2D game type.
Seeds are NOT game mechanics — they are the atomic units mechanics are built from.

### Seed descriptions (engine agnostic)
Live in pipeline/seeds/ as .md files.
Describe behavior only — no engine-specific code.
Each description covers:
- What this seed does
- What inputs it accepts
- What outputs and signals it emits
- What it never does
- One usage example

### Engine implementations
Live in engines/{engine}/seeds/ as code files.
Each implementation:
- Under 50 lines
- Does exactly one thing
- No dependencies on other seeds
- Zero errors guaranteed in target engine version
- Fully configurable via exported variables

### The 14 seeds

Tier 1 — Universal (every game)
- player_controller — handles player input and basic control
- camera — follows subject, handles bounds and zoom
- scene_manager — transitions, loading, screen management
- game_state — win/lose/pause/play, global flags

Tier 2 — Very Common (most games)
- autonomous_mover — moves without player input, configurable behavior
- interactable — responds when player engages with it
- resource — tracked value with min/max (health, score, ammo, currency)
- audio_manager — plays sounds and music, handles volume
- ui_element — displays any information on screen

Tier 3 — Common (many games)
- detector — notices proximity, entry, or line of sight
- spawner — creates instances at runtime on demand or on timer
- projectile — travels in a direction, hits something, disappears
- dialogue — presents text, waits for player response
- timer_event — triggers something after elapsed time

### How mechanics are built from seeds

Monster that chases player:
  autonomous_mover + detector + game_state

Locked door:
  interactable + game_state + scene_manager

Shop NPC:
  interactable + dialogue + resource

Platformer enemy:
  autonomous_mover + detector + projectile

Bullet hell boss:
  autonomous_mover + spawner + projectile + timer_event + resource

Collectible coin:
  interactable + resource + audio_manager

Dialogue NPC:
  interactable + dialogue

Checkpoint:
  detector + game_state + scene_manager

Turret:
  detector + projectile + timer_event

---

## Approval Flow

### Three change types
- Immediate — value tweaks, text changes — applies instantly, no approval
- Preview first — art generation, new levels — user sees before applying
- Explicit confirm — destructive changes — always ask first

### Preview flow
Generate → show all previous attempts → directed feedback → regenerate →
repeat until approved → apply

### Key rules
- Never lose previous attempts — user can always go back
- User never sees error messages — validator handles silently
- User only sees: generating / ready

---

## Pipeline Flow

The correct generation order for every new game. Do not skip or reorder steps.

1. **Visual direction first** — user provides reference images or approves a generated mood board before any code is written
2. **Art Director generates tileset only** — user approves the tileset; this image becomes the style reference for all subsequent assets
3. **Engineer builds game logic with placeholder art** — fully playable build using solid-color placeholders, no blocking on real art
4. **Art Director generates all remaining assets** — characters, items, props, UI — all using the approved tileset as `style_reference_url`
5. **Validator runs silently** — fixes any file errors before user sees anything
6. **User playtests** — first time user sees real art is in a working build

Nothing in step 4 begins before step 2 is approved.
Nothing in step 3 blocks on step 4.

---

## Art Adapter System

Art adapters live in art/{service}/adapter.md
Current adapters:
- art/pixellab/ — PixelLab API integration
- art/upload/ — user provided sprites

Adding a new art service = add a new folder, implement the adapter interface
The Art Director never calls PixelLab directly — always through the adapter

---

## Engine Adapter System

Engine adapters live in engines/{engine}/
Current engines:
- engines/godot/ — Godot 4.6.3

Each engine folder contains:
- seeds/ — implementations of all 14 seeds for that engine
- builder.md — how to assemble a complete project in this engine
- scene_format.md — how scene files work in this engine
- export.md — how to export builds in this engine

Adding a new engine = add a new folder, implement all 14 seeds
The Engineer never writes Godot-specific code directly — always uses engine adapter

---

## Output Stages
1. Godot project folder — now
2. Zip download — soon
3. Playable web build with shareable link — next
4. itch.io publishing — later
5. Steam publishing — future

---

## Game Page
Each published game gets:
- Shareable link
- Play in browser (HTML5 export)
- Download project option
- Play count and remix count
- Three visibility tiers: Private / Public / Open (remixable)

### Remix system
- Only open games can be remixed
- Remixes start from the game spec JSON, not the art or code
- Fresh assets generated using remixer's credits
- Attribution chain maintained

---

## Reference Image Support
Users can provide:
- Mood reference — overall vibe and atmosphere
- Style reference — passed to art adapter for generation guidance
- Character reference — guides character sprite generation
- Map reference — guides level layout decisions
- Color palette — extracted and applied to all assets
- Existing sprites — bypass art generation entirely
- Existing project — pipeline reads and extends it

---

## Speed Targets
- Under 1 minute: playable placeholder build
- Under 10 minutes: fully generated game with real art
- Under 20 minutes: polished version after first feedback round

---

## Community Contributions
Community can submit:
- New seed implementations for existing engines
- New engine adapters
- New art adapters
- Bug fixes to existing seeds

Community cannot submit:
- Changes to seed descriptions (pipeline/seeds/) — maintained by core team
- Changes to agent prompts — private
- Changes to skills — private

Automated checks on all PRs:
- Code syntax valid
- No OS.execute() calls
- No file system access outside project
- No HTTP requests
- No naming conflicts
- Documentation headers present

---

## Open Source Policy
Public (this repo):
- Seed descriptions (pipeline/seeds/)
- Engine implementations (engines/)
- Art adapters (art/)
- Tools (pixellab-mcp, setup)
- Presets
- Documentation

Private (not in this repo):
- Agent system prompts (pipeline/agents/)
- Skills implementation (pipeline/skills/)
- Pipeline orchestration logic
- Hosted backend code

The seeds and engines are the community hook.
The pipeline intelligence is the moat.

---

## Privacy Rules
- Never hardcode API keys anywhere
- Never hardcode file paths anywhere
- Everything configurable via .env
- .env is always gitignored
- claude_desktop_config.json always gitignored

## Environment Variables Required
```
PIXELLAB_API_KEY=
ANTHROPIC_API_KEY=
GODOT_PROJECTS_PATH=
GAME_STUDIO_PATH=
```

---

## Repo Structure

```
ai-game-studio/
  pipeline/
    seeds/              <- 14 engine-agnostic seed descriptions (.md)
      tier1/
      tier2/
      tier3/
    agents/             <- private, not in public repo
    skills/             <- private, not in public repo

  engines/
    godot/
      seeds/            <- 14 Godot 4 implementations (.gd)
      builder.md        <- how to assemble a Godot project
      scene_format.md   <- Godot scene file reference
      export.md         <- how to export Godot builds

  art/
    pixellab/
      adapter.md        <- PixelLab API integration spec
    upload/
      adapter.md        <- user upload handler spec

  presets/
    horror_escape.json
    rpg.json
    platformer.json
    puzzle.json

  tools/
    pixellab-mcp/       <- downloads PixelLab assets locally
    setup/
      setup.bat         <- Windows one-click install
      setup.sh          <- Mac/Linux one-click install

  games/                <- gitignored, generated games live here

  .github/
    workflows/
      validate_module.yml

  .env.example
  .gitignore
  README.md
  CLAUDE.md             <- this file
```

---

## Current Phase
Phase 1 — Restructure repo to seed-based engine-agnostic architecture

## Next Steps
1. Delete features/ folder
2. Create pipeline/seeds/ with 14 .md descriptions
3. Create engines/godot/seeds/ with 14 .gd implementations
4. Create art/pixellab/adapter.md and art/upload/adapter.md
5. Update README.md
6. Commit and push to GitHub
7. Test: one prompt generates a complete playable game end to end

## Prototype Reference
A working horror escape prototype exists locally in the Godot projects folder.
It proved the pipeline concept works and provided the original verified scripts.
The seeds in engines/godot/ are derived from that prototype but generalized
to be reusable across any game type.

---

## Pipeline Discipline

Rules learned from building The Three Keys. Enforced on all future games.

### Script placement
- Never write temporary or generation scripts to the repo root
- All game-specific scripts go in `games/{game-title}/tools/`
- Temporary generation scripts are deleted after use, not committed

### TileMap
- TileMap must always use 2 layers minimum
  - Layer 0 "Ground" — ground tile, no collision
  - Layer 1 "Trees" / "Walls" — obstacle tile, collision enabled on every tile
- TileSet physics layer must be added to the TileSet **before** calling `get_tile_data()` or `add_collision_polygon()` — configuring collision before `add_source()` silently no-ops
- Engineer follows genre-specific TileMap rules from `engines/godot/builder.md`

### Character sprites
- Character sprites must always include walk animations: 4 directions × 4 frames minimum
  - `walk_down_1..4`, `walk_up_1..4`, `walk_left_1..4`, `walk_right_1..4`
  - Plus an `idle` frame (at minimum one frame from the base sprite)
- Art Director follows genre-specific animation requirements from `art/pixellab/adapter.md`

### AnimatedSprite2D driving
- Always use `_physics_process` with direct `Input.get_axis()` reading
- Never use signal-based animation driving (`moved`, `stopped` signals)
- Store the last animation name in a variable; only call `play()` when it changes
- This prevents per-frame restarts and eliminates flicker from repeated `play()` calls

---

## Git Workflow

- Default branch is `dev` — all work happens here
- `main` is for stable releases only — never push directly to `main`
- Always pull before starting work: `git checkout dev && git pull`
- Commit frequently with descriptive messages
- To release a stable version: `git checkout main && git merge dev && git push && git checkout dev`

When generating games or making any changes, always confirm you are on the `dev` branch before committing.
