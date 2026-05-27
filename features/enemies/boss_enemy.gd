# FEATURE: boss_enemy
# STATUS: placeholder
# DESCRIPTION: Multi-phase boss with distinct attack patterns per health threshold.
# EXPORTS: max_health, phase_thresholds
# DEPENDENCIES: CharacterBody2D, AnimationPlayer

extends CharacterBody2D

@export var max_health: float = 500.0
@export var phase_thresholds: Array[float] = [0.66, 0.33]

var health: float
var current_phase: int = 0

signal phase_changed(phase: int)

func _ready() -> void:
	health = max_health

func take_damage(amount: float) -> void:
	health -= amount
	_check_phase()
	if health <= 0.0:
		queue_free()

func _check_phase() -> void:
	for i in phase_thresholds.size():
		if health / max_health <= phase_thresholds[i] and current_phase == i:
			current_phase = i + 1
			phase_changed.emit(current_phase)
			break
