# FEATURE: companions
# STATUS: placeholder
# DESCRIPTION: Companion that follows the player at a set offset using NavigationAgent2D.
# EXPORTS: follow_distance, move_speed
# DEPENDENCIES: CharacterBody2D, NavigationAgent2D

extends CharacterBody2D

@export var follow_distance: float = 60.0
@export var move_speed: float = 130.0

var player: Node2D = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var dist := global_position.distance_to(player.global_position)
	if dist <= follow_distance:
		return
	nav_agent.target_position = player.global_position
	if not nav_agent.is_navigation_finished():
		velocity = (nav_agent.get_next_path_position() - global_position).normalized() * move_speed
		move_and_slide()
