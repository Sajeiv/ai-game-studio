# FEATURE: topdown_movement
# STATUS: verified
# DESCRIPTION: 8-directional top-down player movement with configurable speed.
# INPUTS: WASD / arrow keys
# EXPORTS: speed (float)
# DEPENDENCIES: CharacterBody2D

extends CharacterBody2D

@export var speed: float = 150.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
