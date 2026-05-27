# SEED: audio_manager
# STATUS: verified
# DESCRIPTION: Singleton — plays SFX and music, controls bus volumes.
# EXPORTS: sfx_bus, music_bus, default_music, music_volume, sfx_volume
# SIGNALS: music_started(path), music_stopped(), sfx_played(path)
# NOTE: Register as autoload named AudioManager in Project Settings.

extends Node

@export var sfx_bus: StringName = &"SFX"
@export var music_bus: StringName = &"Music"
@export var default_music: AudioStream = null
@export var music_volume: float = 0.0
@export var sfx_volume: float = 0.0

signal music_started(stream_path: String)
signal music_stopped()
signal sfx_played(stream_path: String)

var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = music_bus
	add_child(_music_player)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	if default_music:
		play_music(default_music)

func play_music(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()
	music_started.emit(stream.resource_path)

func stop_music() -> void:
	_music_player.stop()
	music_stopped.emit()

func play_sfx(stream: AudioStream) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.bus = sfx_bus
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
	sfx_played.emit(stream.resource_path)

func set_music_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(music_bus), db)

func set_sfx_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(sfx_bus), db)
