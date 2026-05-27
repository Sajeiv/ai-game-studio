# FEATURE: game_manager
# STATUS: verified
# DESCRIPTION: Autoload singleton that tracks global game state and win/lose conditions.
# EXPORTS: none
# DEPENDENCIES: add as Autoload in project settings

extends Node

var game_active: bool = false

signal game_won
signal game_lost

func start_game() -> void:
	game_active = true

func trigger_win() -> void:
	if not game_active:
		return
	game_active = false
	game_won.emit()

func trigger_loss() -> void:
	if not game_active:
		return
	game_active = false
	game_lost.emit()
