# FEATURE: patrol_only
# STATUS: placeholder
# DESCRIPTION: Enemy patrols between a set of waypoints; ignores the player.
# EXPORTS: waypoints (Array[Vector2]), patrol_speed
# DEPENDENCIES: CharacterBody2D

extends CharacterBody2D

@export var patrol_speed: float = 60.0
@export var waypoints: Array[Vector2] = []

var current_point: int = 0

func _physics_process(_delta: float) -> void:
	if waypoints.is_empty():
		return
	var target := waypoints[current_point]
	var diff := target - global_position
	if diff.length() < 4.0:
		current_point = (current_point + 1) % waypoints.size()
	else:
		velocity = diff.normalized() * patrol_speed
		move_and_slide()
