# Seed: timer_event

## What this seed does
Fires a triggered() signal after a configurable delay. Supports one-shot and looping modes. Can be started, stopped, and reset programmatically. Multiple timer_event nodes can be composed to build complex timing sequences without writing custom timer logic.

## Inputs accepted
- `wait_time` — seconds to wait before firing (default 1.0)
- `loop` — whether to restart automatically after each firing (default false)
- `autostart` — whether to begin counting down immediately on scene ready (default false)

## Outputs and signals
- `triggered()` — emitted when the timer reaches zero
- `started()` — emitted when the timer starts or restarts
- `stopped()` — emitted when the timer is manually stopped before completion

## What it never does
- Does not know what should happen when it fires — connect triggered() externally
- Does not accumulate or count firings internally
- Does not synchronize across multiple instances

## Usage example
Timed bomb collectible: timer_event on the bomb node, wait_time=5.0, autostart=true, loop=false. triggered() connects to a function that calls spawner.spawn() for an explosion effect and GameState.set_flag("bomb_exploded", true).
