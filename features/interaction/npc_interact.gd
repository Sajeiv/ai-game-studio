# FEATURE: npc_interact
# STATUS: placeholder
# DESCRIPTION: NPC that triggers dialogue when the player presses the interact key nearby.
# EXPORTS: interact_key, proximity_radius
# DEPENDENCIES: Area2D, dialogue feature

extends Area2D

@export var interact_key: String = "ui_accept"
@export var proximity_radius: float = 60.0

var player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_just_pressed(interact_key):
		if has_node("Dialogue"):
			get_node("Dialogue").start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
