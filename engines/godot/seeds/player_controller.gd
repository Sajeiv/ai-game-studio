# SEED: player_controller
# STATUS: verified
# DESCRIPTION: Reads player input and moves a CharacterBody2D. 8-directional, configurable speed.
# EXPORTS: speed, input_left, input_right, input_up, input_down
# SIGNALS: moved(direction), stopped()

extends CharacterBody2D

@export var speed: float = 150.0
@export var input_left: StringName = &"ui_left"
@export var input_right: StringName = &"ui_right"
@export var input_up: StringName = &"ui_up"
@export var input_down: StringName = &"ui_down"

signal moved(direction: Vector2)
signal stopped()

var _was_moving := false

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector(input_left, input_right, input_up, input_down)
	velocity = dir * speed
	move_and_slide()
	if dir != Vector2.ZERO:
		_was_moving = true
		moved.emit(dir)
	elif _was_moving:
		_was_moving = false
		stopped.emit()
