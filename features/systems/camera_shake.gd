# FEATURE: camera_shake
# STATUS: placeholder
# DESCRIPTION: Applies a randomised offset to a Camera2D for a set duration and intensity.
# EXPORTS: none
# DEPENDENCIES: Camera2D (attach this script to it)

extends Camera2D

var shake_duration: float = 0.0
var shake_intensity: float = 0.0

func shake(duration: float, intensity: float) -> void:
	shake_duration = duration
	shake_intensity = intensity

func _process(delta: float) -> void:
	if shake_duration > 0.0:
		shake_duration -= delta
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		offset = Vector2.ZERO
