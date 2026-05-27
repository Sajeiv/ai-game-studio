# FEATURE: stamina
# STATUS: verified
# DESCRIPTION: Stamina resource that drains on sprint and regenerates when idle.
# EXPORTS: max_stamina, drain_rate, regen_rate, sprint_key
# DEPENDENCIES: attach to player; pairs with topdown_movement or platformer_movement

extends Node

@export var max_stamina: float = 100.0
@export var drain_rate: float = 20.0
@export var regen_rate: float = 10.0
@export var sprint_key: String = "sprint"

var current: float

signal stamina_changed(value: float)

func _ready() -> void:
	current = max_stamina

func _process(delta: float) -> void:
	if Input.is_action_pressed(sprint_key) and current > 0.0:
		current = maxf(current - drain_rate * delta, 0.0)
	else:
		current = minf(current + regen_rate * delta, max_stamina)
	stamina_changed.emit(current)

func is_sprinting() -> bool:
	return Input.is_action_pressed(sprint_key) and current > 0.0
