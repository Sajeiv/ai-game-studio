# FEATURE: chaser
# STATUS: verified
# DESCRIPTION: Enemy that chases the player on sight using NavigationAgent2D.
# EXPORTS: speed, detection_radius
# DEPENDENCIES: CharacterBody2D, NavigationAgent2D, Area2D detection zone

extends CharacterBody2D

@export var speed: float = 80.0
@export var detection_radius: float = 200.0

var target: Node2D = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _physics_process(_delta: float) -> void:
	if target == null:
		return
	nav_agent.target_position = target.global_position
	if not nav_agent.is_navigation_finished():
		velocity = (nav_agent.get_next_path_position() - global_position).normalized() * speed
		move_and_slide()

func set_target(node: Node2D) -> void:
	target = node
