# Skill: classify_change

## Purpose
Classify a user change request into one of three action types so the Producer routes it correctly.

## Inputs
- `change_request` — the user's message describing what they want changed
- `current_spec` — the current game spec JSON

## Outputs
```json
{
  "type": "immediate | preview | confirm",
  "scope": ["list of affected spec fields or file types"],
  "description": "one-line summary of what will change"
}
```

## Classification Rules

| Type | When to use |
|------|-------------|
| `immediate` | Value tweaks, text changes, speed/stat adjustments — no art, no structural change |
| `preview` | Any art regeneration, new level, new feature module, layout change |
| `confirm` | Start over, delete a level, remove a core mechanic, destructive scope |

## Notes
- When in doubt, escalate to `preview` rather than `immediate`
- `confirm` is only for changes that cannot be undone without re-running the full pipeline
