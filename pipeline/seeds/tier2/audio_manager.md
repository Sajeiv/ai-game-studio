# Seed: audio_manager

## What this seed does
Plays sound effects and background music. Manages audio bus volumes for SFX and Music independently. Provides play, stop, fade_in, and fade_out methods. Registers as an autoload singleton so any node can trigger sounds without keeping a direct reference.

## Inputs accepted
- `sfx_bus` — AudioBus name for sound effects (default "SFX")
- `music_bus` — AudioBus name for music (default "Music")
- `default_music` — AudioStream to begin playing automatically on ready (optional)
- `music_volume` — initial music bus volume in dB (default 0)
- `sfx_volume` — initial SFX bus volume in dB (default 0)

## Outputs and signals
- `music_started(stream_path: String)` — emitted when a music track begins
- `music_stopped()` — emitted when music stops
- `sfx_played(stream_path: String)` — emitted when a sound effect plays

## What it never does
- Does not store AudioStreamPlayer nodes inside other seeds — it manages its own internal pool
- Does not handle positional 3D audio
- Does not mix voice-over audio on a separate channel

## Usage example
Platformer: audio_manager autoload with default_music set to the level theme stream. The resource seed's depleted signal connects to AudioManager.play_sfx(death_sound). A settings menu calls AudioManager.set_music_volume(-80) to mute.
