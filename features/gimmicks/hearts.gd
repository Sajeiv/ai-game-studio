# FEATURE: hearts
# STATUS: placeholder
# DESCRIPTION: Zelda-style heart-based health system; health measured in half-heart increments.
# EXPORTS: max_hearts
# DEPENDENCIES: Node; pairs with hud or health_bar

extends Node

@export var max_hearts: int = 3

var half_hearts: int

signal hearts_changed(half_hearts: int)
signal died

func _ready() -> void:
	half_hearts = max_hearts * 2

func take_damage(half_heart_amount: int = 1) -> void:
	half_hearts = maxi(half_hearts - half_heart_amount, 0)
	hearts_changed.emit(half_hearts)
	if half_hearts == 0:
		died.emit()

func heal(half_heart_amount: int = 2) -> void:
	half_hearts = mini(half_hearts + half_heart_amount, max_hearts * 2)
	hearts_changed.emit(half_hearts)
