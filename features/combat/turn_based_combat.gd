# FEATURE: turn_based_combat
# STATUS: placeholder
# DESCRIPTION: Simple turn-based combat state machine with player and enemy turns.
# EXPORTS: none
# DEPENDENCIES: Node; connect to UI buttons for player actions

extends Node

enum Turn { PLAYER, ENEMY }

var current_turn: Turn = Turn.PLAYER
var combatants: Array[Node] = []

signal turn_changed(turn: Turn)
signal combat_ended(player_won: bool)

func start_combat(player: Node, enemy: Node) -> void:
	combatants = [player, enemy]
	current_turn = Turn.PLAYER
	turn_changed.emit(current_turn)

func player_action(damage: float) -> void:
	if current_turn != Turn.PLAYER:
		return
	var enemy: Node = combatants[1]
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	if not is_instance_valid(enemy):
		combat_ended.emit(true)
		return
	_next_turn()

func _next_turn() -> void:
	current_turn = Turn.ENEMY if current_turn == Turn.PLAYER else Turn.PLAYER
	turn_changed.emit(current_turn)
