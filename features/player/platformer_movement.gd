# FEATURE: platformer_movement
# STATUS: placeholder
# DESCRIPTION: Side-scrolling platformer movement with jump and gravity.
# INPUTS: left/right to move, jump button to jump
# EXPORTS: speed, jump_velocity, gravity
# DEPENDENCIES: CharacterBody2D

extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	move_and_slide()
