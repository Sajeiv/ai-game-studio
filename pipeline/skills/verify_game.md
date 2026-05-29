# Skill: verify_game

## Purpose
Play through a generated Godot game as an AI QA tester before declaring it playtest-ready.
You observe the game through screenshots, decide what to do next, act, and verify the outcome.
No playthrough steps are pre-scripted — you figure out the game by looking at it.

## When to run
Always run this skill before handing a build to the user.
Never skip it. A build that hasn't been verified is not ready.

## Tool
`tools/playtest_actions.ps1` — exposes five primitives you call one at a time:

```powershell
# Launch the game — returns a window handle ($hwnd)
$hwnd = & "$RepoRoot\tools\playtest_actions.ps1" -Action launch `
    -ProjectPath $ProjectPath -GameName $GameName -ScreenshotDir $SsDir

# Capture current frame — returns the saved path
$path = & "$RepoRoot\tools\playtest_actions.ps1" -Action screenshot `
    -Hwnd $hwnd -Label "descriptive_label" -ScreenshotDir $SsDir

# Tap a key once
& "$RepoRoot\tools\playtest_actions.ps1" -Action press -Hwnd $hwnd -Key e

# Hold a direction key for N ms
& "$RepoRoot\tools\playtest_actions.ps1" -Action hold -Hwnd $hwnd -Key down -Ms 1500

# Wait N ms (let physics settle, scene load)
& "$RepoRoot\tools\playtest_actions.ps1" -Action wait -Ms 1000

# Stop the game
& "$RepoRoot\tools\playtest_actions.ps1" -Action stop -Hwnd $hwnd
```

Supported keys: `up` `down` `left` `right` `e` `space` `enter` `escape` `shift` `r` `w` `a` `s` `d`

---

## The AI Playtester Loop

You are the playtester. You drive the loop:

```
launch game
  └─ screenshot → read with vision → understand state
       └─ decide next action
            └─ execute action
                 └─ screenshot → read with vision → verify outcome
                      └─ if unexpected → log issue, try to recover or stop
                      └─ if expected   → decide next action → ...
```

Keep going until you reach the win/end state, or until you confirm a game-breaking issue.

---

## What to check with vision at each screenshot

Do not just verify "no black screen." Think like a QA tester:

| What you see | What to verify |
|---|---|
| Main menu | Title visible, prompt visible, not black, not crashed |
| Level loaded | Player sprite visible, HUD visible, world rendered (not black) |
| Near a key/collectible | Object visible on screen |
| After walking over key | Key disappeared, HUD counter incremented |
| At a door needing keys | Door visible; if keys not collected, door should NOT open on E press |
| At a door with keys collected | E press triggers scene transition |
| Enemy in same room | Enemy is moving (not frozen at spawn); if player in line of sight, enemy reacts |
| Caught by enemy | Game over screen appears |
| Win condition met | Win screen appears, text readable |

---

## What counts as a game-breaking issue

Stop and fix immediately if you observe any of these:

- Black screen after launch (renderer crash or scene load failure)
- Player invisible or stuck at spawn (collision or script error)
- Collectible not disappearing after player walks over it (trigger not wired)
- Door does not respond to E key when keys collected (interact logic broken)
- Door opens when it shouldn't (keys_required check missing)
- Enemy frozen at spawn position, not moving (autonomous_mover not initialised)
- Enemy reaches player but game over screen does not appear (catch signal not connected)
- Special NPC (e.g. Riley) does not respond to E key (interactable not wired)
- Win condition not triggering after all objectives met
- HUD not updating when state changes
- Runtime SCRIPT ERROR lines in `%APPDATA%\Godot\app_userdata\<game>\logs\godot.log`

---

## How to fix issues found during playtest

1. Stop the game (`-Action stop`)
2. Read the relevant scripts and identify the root cause
3. Apply the fix
4. Re-launch from the top — do not resume mid-session
5. Repeat until a full playthrough completes without issues

---

## Pass criteria

You may hand the build to the user when:
- Full game loop completed in one session without intervention
- All objectives reachable (keys collectible, doors openable, NPCs interactable)
- Enemy behaviour correct (moves, detects, triggers game over)
- Win/lose screens appear at the right times
- No SCRIPT ERROR lines in the runtime log

---

## Notes

- Use `hold` for movement (duration drives distance). Start with short holds and observe before committing to long ones.
- Use `wait` after scene transitions (1500–2500 ms) to let the new level load.
- If the player appears stuck against a wall, try a perpendicular direction to navigate around it.
- Screenshots are numbered automatically. Read them in order to reconstruct what happened.
- The game runs at ~60 fps. A 1000 ms hold at speed 150 px/s moves the player ~150 world px.
