# SEED: game_state
# STATUS: verified
# DESCRIPTION: Singleton — tracks game phase and arbitrary named flags.
# SIGNALS: phase_changed(phase), flag_changed(key, value), game_won(), game_lost()
# NOTE: Register as autoload named GameState in Project Settings.

extends Node

enum GamePhase { MENU, PLAYING, PAUSED, WIN, LOSE }

signal phase_changed(new_phase: GamePhase)
signal flag_changed(key: String, value: Variant)
signal game_won()
signal game_lost()

var phase: GamePhase = GamePhase.PLAYING:
	set(value):
		phase = value
		phase_changed.emit(value)
		if value == GamePhase.WIN:
			game_won.emit()
		elif value == GamePhase.LOSE:
			game_lost.emit()

var _flags: Dictionary = {}

func set_flag(key: String, value: Variant) -> void:
	_flags[key] = value
	flag_changed.emit(key, value)

func get_flag(key: String, default: Variant = null) -> Variant:
	return _flags.get(key, default)

func reset() -> void:
	_flags.clear()
	phase = GamePhase.PLAYING
