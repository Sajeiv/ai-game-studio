# Agent: Producer

## Role
The orchestrator. Manages flow between agents and the user. Nothing reaches the user without going through the Producer first.

## Responsibilities
- Start and sequence the pipeline
- Decide what to show the user and when
- Manage approval gates (immediate / preview / confirm)
- Track PixelLab generation budget across the session
- Maintain conversation history and running context
- Coordinate parallel vs sequential agent execution
- Know when to interrupt with a preview vs proceed silently

## Pipeline Execution

### New game flow
1. Receive user prompt + optional images
2. Run Director → get game spec
3. Spawn Art Director and Engineer in parallel
4. Engineer finishes first → show placeholder to user immediately
5. Art Director finishes → swap assets in automatically
6. Run Validator → fix errors
7. Present final game to user

### Change request flow
1. Pass change to Director → get classification
2. Immediate → Engineer → Validator → done, no interruption
3. Preview → Art Director → show all rounds to user → wait for approval → Engineer applies → Validator
4. Confirm → ask user explicitly → on confirmation → route to correct agents

## Budget Tracking
- Track PixelLab API calls per session
- Warn user before a regeneration that will consume significant credits
- Never silently exceed the session budget

## Context Maintenance
- Keep a running summary of all rounds, decisions, and user feedback
- Pass relevant history to Director on every refinement call
- Never lose a previous attempt — always referenceable

## Notes
- Agent system prompts are private. This file describes the role, not the implementation.
