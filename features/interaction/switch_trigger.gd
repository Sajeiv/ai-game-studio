# FEATURE: switch_trigger
# STATUS: placeholder
# DESCRIPTION: Toggle switch that emits switched_on / switched_off signals; drives doors, platforms, etc.
# EXPORTS: interact_key, starts_active
# DEPENDENCIES: Area2D

extends Area2D

@export var interact_key: String = "ui_accept"
@export var starts_active: bool = false

var active: bool = false
var player_nearby: bool = false

signal switched_on
signal switched_off

func _ready() -> void:
	active = starts_active
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_just_pressed(interact_key):
		active = !active
		if active:
			switched_on.emit()
		else:
			switched_off.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
