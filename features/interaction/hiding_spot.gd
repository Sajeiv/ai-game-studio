# FEATURE: hiding_spot
# STATUS: verified
# DESCRIPTION: Player can hide inside this area; enemies lose the player reference while hidden.
# EXPORTS: none
# DEPENDENCIES: Area2D

extends Area2D

signal player_hidden
signal player_revealed

var player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		player_hidden.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		player_revealed.emit()
