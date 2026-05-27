# FEATURE: pointandclick
# STATUS: placeholder
# DESCRIPTION: Click-to-move point-and-click navigation using NavigationAgent2D.
# INPUTS: left mouse click to set destination
# EXPORTS: move_speed
# DEPENDENCIES: CharacterBody2D, NavigationAgent2D

extends CharacterBody2D

@export var move_speed: float = 120.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		nav_agent.target_position = get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	velocity = (nav_agent.get_next_path_position() - global_position).normalized() * move_speed
	move_and_slide()
