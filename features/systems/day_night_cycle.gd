# FEATURE: day_night_cycle
# STATUS: placeholder
# DESCRIPTION: Modulates a CanvasModulate to cycle between day and night over a configurable duration.
# EXPORTS: day_duration_seconds, day_color, night_color
# DEPENDENCIES: CanvasModulate child node

extends Node

@export var day_duration_seconds: float = 120.0
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var night_color: Color = Color(0.1, 0.1, 0.25)

@onready var modulate_node: CanvasModulate = $CanvasModulate

var elapsed: float = 0.0

func _process(delta: float) -> void:
	elapsed = fmod(elapsed + delta, day_duration_seconds)
	var t := elapsed / day_duration_seconds
	# 0→0.5 = day→night, 0.5→1.0 = night→day
	var blend := sin(t * PI)
	modulate_node.color = day_color.lerp(night_color, blend)
