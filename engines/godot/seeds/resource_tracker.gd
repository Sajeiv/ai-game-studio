# SEED: resource
# STATUS: verified
# DESCRIPTION: Tracks a clamped numeric value — health, ammo, score, currency, or any quantity.
# EXPORTS: resource_name, max_value, min_value, initial_value
# SIGNALS: value_changed(new, old), depleted(), full()
# NOTE: File named resource_tracker.gd to avoid shadowing Godot's built-in Resource class.

extends Node

@export var resource_name: String = "resource"
@export var max_value: float = 100.0
@export var min_value: float = 0.0
@export var initial_value: float = 100.0

signal value_changed(new_value: float, old_value: float)
signal depleted()
signal full()

var value: float:
	set(v):
		var old := value
		value = clampf(v, min_value, max_value)
		if value != old:
			value_changed.emit(value, old)
			if value <= min_value:
				depleted.emit()
			elif value >= max_value:
				full.emit()

func _ready() -> void:
	value = initial_value

func add(amount: float) -> void:
	value += amount

func subtract(amount: float) -> void:
	value -= amount

func reset() -> void:
	value = initial_value
