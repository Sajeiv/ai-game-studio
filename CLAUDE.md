# AI Game Studio — Project Context

## Vision
An AI-powered game generation platform. Users describe a game in natural language, AI builds it automatically. Think RPG Maker but fully AI driven. No game development experience required.

## Core Promise
Talk to AI, get a playable game.

## Design Principles
- Feature-based not game-type-based
- Surgical edits not full regeneration
- Parallel generation wherever possible
- Instant placeholder builds — playable in under a minute
- Full history shown during refinement rounds
- Smart defaults — only pause for approval when it matters
- Progressive onboarding — ask for accounts only when needed
- Privacy first — no hardcoded paths or API keys ever

---

## Tech Stack
- Godot 4 — game engine (plain text files, exports everywhere, free)
- PixelLab API — AI pixel art generation
- Claude Code — orchestrates the entire pipeline
- pixellab-godot MCP — custom Node.js server, downloads assets locally
- Node.js — runs MCP servers

---

## Agent System

### Agent 1 — Director
The brain. Runs first, runs last, supervises everything.
- Interprets user prompt and reference images
- Produces structured game spec JSON
- Makes creative decisions when user doesn't specify
- Coordinates which agents run and in what order
- Classifies change requests (immediate / preview / confirm)
- Synthesizes feedback across refinement rounds
- Reads MANIFEST.md to know available features

### Agent 2 — Art Director
Everything visual.
- Generates sprites, tilesets, items, UI art via PixelLab
- Maintains visual consistency across all assets
- Manages refinement history (all attempts kept)
- Extracts color palette from reference images
- Downloads all assets via pixellab-godot MCP
- Passes style references to PixelLab correctly

### Agent 3 — Engineer
Everything technical.
- Reads feature library, picks correct modules
- Generates new gimmick code when needed
- Writes all GDScript files and scene files (.tscn)
- Writes SpriteFrames resources (.tres)
- Wires everything together correctly
- Handles surgical edits — changes only what's needed
- Reads existing Godot projects for import feature

### Agent 4 — Validator
The safety net. Always runs before user sees anything.
- Reads every generated file
- Catches syntax errors before user runs the game
- Checks cross-file dependencies
- Verifies all referenced nodes exist in scenes
- Fixes errors automatically where possible
- Reports what was fixed and what needs manual attention

### Agent 5 — Producer
The orchestrator. Manages flow between agents and user.
- Decides what to show user and when
- Manages approval gates
- Tracks PixelLab generation budget
- Maintains conversation history and context
- Coordinates parallel vs sequential agent execution
- Knows when to interrupt with preview vs proceed silently

---

## Skills Library
Reusable capabilities any agent can call:

- analyze_image — extract style, mood, palette from reference images
- extract_game_spec — turn natural language into structured JSON
- classify_change — immediate vs preview vs confirm
- read_godot_project — parse existing project structure
- generate_scene_file — write valid .tscn files
- generate_spriteframes — write valid .tres SpriteFrames resources
- validate_gdscript — check GDScript for common errors
- surgical_edit — modify specific files without touching others
- export_godot — trigger Godot export to web/desktop builds
- write_game_page — generate title, description, cover art prompt

---

## Approval Flow

### Three change types:
- Immediate — value tweaks, text changes — applies instantly, no approval
- Preview first — art generation, new levels — user sees before applying
- Explicit confirm — destructive changes like start over — always ask

### Preview flow:
Generate → Show all previous attempts → Directed feedback → Regenerate →
Repeat until approved → Apply

### Key rule:
Never lose previous attempts. User can always go back to Round 1.

---

## Feature Library Structure

```
features/
  player/
    topdown_movement.gd        (verified)
    platformer_movement.gd
    pointandclick.gd
  enemies/
    chaser.gd                  (verified)
    patrol_only.gd
    ranged_shooter.gd
    boss_enemy.gd
  interaction/
    inventory.gd               (verified)
    pickup_item.gd             (verified)
    locked_door.gd             (verified)
    hiding_spot.gd             (verified)
    dialogue.gd
    npc_interact.gd
    switch_trigger.gd
  combat/
    no_combat.gd               (verified)
    melee_combat.gd
    ranged_combat.gd
    turn_based_combat.gd
  ui/
    hud.gd                     (verified)
    game_over.gd               (verified)
    win_screen.gd              (verified)
    intro_screen.gd            (verified)
    dialogue_box.gd
    inventory_ui.gd
    health_bar.gd
  systems/
    game_manager.gd            (verified)
    save_load.gd
    day_night_cycle.gd
    camera_shake.gd
    scene_transition.gd
  gimmicks/
    stamina.gd                 (verified)
    hearts.gd
    companions.gd
    time_rewind.gd
```

---

## Pipeline Flow

```
User prompt + optional reference images
         |
Producer: starts pipeline
         |
Director: analyzes input → game spec JSON
         |
Producer: runs Art Director + Engineer in PARALLEL
         |
Art Director: generates assets (5-10 mins async)
Engineer: builds placeholder game (1-2 mins)
         |
Producer: placeholder ready → show user immediately
          art finishes → swap in automatically
         |
Validator: checks everything → fixes errors
         |
Producer: game is ready → user plays
         |
User requests change
         |
Director: classifies change type
         |
Immediate → Engineer edits → Validator checks → done
Preview   → Art Director generates → shows history →
            user refines → approved → Engineer applies
Confirm   → ask user → confirmed → agents execute
```

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

### Remix system:
- Only open games can be remixed
- Remixes start from the game spec JSON, not the art
- Fresh assets generated using remixer's PixelLab credits
- Attribution chain maintained: "Remixed from X by Y"

---

## Reference Image Support
Users can provide:
- Mood reference — overall vibe and atmosphere
- Style reference — passed directly to PixelLab for art generation
- Character reference — guides character sprite generation
- Map reference — guides level layout decisions
- Color palette — extracted and applied to all assets
- Existing sprites — bypass PixelLab entirely
- Existing Godot project — pipeline reads and extends it

---

## Speed Targets
- Under 1 minute: playable placeholder build
- Under 10 minutes: fully generated game with real art
- Under 20 minutes: polished version after first feedback round

---

## Community Module Submissions

```
features/
  verified/    — reviewed and merged by maintainer
  submitted/   — community PRs, pending review
```

### Automated checks before any PR reaches review:
- GDScript syntax valid
- No OS.execute() calls
- No FileAccess outside project folder
- No HTTP requests
- No naming conflicts with verified modules
- Documentation headers present

---

## Open Source Policy

### Public (in this repo)
- All verified features — the building blocks
- Presets — feature combination configs
- Tools — pixellab-mcp, setup scripts
- Documentation and schemas
- GitHub Actions workflows

### Private (not in this repo)
- Agent system prompts — the intelligence layer
- Pipeline orchestration logic — how agents coordinate
- Skills implementation — how skills work internally
- Any hosted platform backend code

The features are the community hook. The pipeline is the moat.

---

## Privacy Rules
- Never hardcode API keys anywhere
- Never hardcode file paths anywhere
- Everything configurable via .env
- .env is always gitignored
- claude_desktop_config.json always gitignored
- Scan before every push: no personal paths, no keys

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
  features/
    player/
    enemies/
    interaction/
    combat/
    ui/
    systems/
    gimmicks/
    submitted/
  presets/
    horror_escape.json
    rpg.json
  pipeline/
    agents/
      director.md
      art_director.md
      engineer.md
      validator.md
      producer.md
    skills/
      analyze_image.md
      extract_game_spec.md
      classify_change.md
      generate_scene_file.md
      validate_gdscript.md
      surgical_edit.md
      export_godot.md
  tools/
    pixellab-mcp/
    setup/
      setup.bat
  games/
  .github/
    workflows/
      validate_module.yml
  .env.example
  .gitignore
  README.md
  CLAUDE.md
```

---

## Current Phase
Phase 0 — Building the framework repo from scratch in Claude Code

## Next Steps
1. Create full repo structure
2. Port verified features from forest-game prototype
3. Write all agent system prompts
4. Write all skills
5. Write pipeline presets
6. Build pixellab-godot MCP
7. End to end test: one prompt to playable horror escape game
8. Push to GitHub

## Prototype Reference
A working horror escape prototype exists at:
Godot/forest-game (in Documents)

Verified features there can be copied directly into features/ here.
That project proves the pipeline works. This repo is the clean framework
built on top of those lessons.
