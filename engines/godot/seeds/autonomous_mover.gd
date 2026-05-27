# SEED: autonomous_mover
# STATUS: verified
# DESCRIPTION: Moves a CharacterBody2D without player input. Modes: PATROL, CHASE, WANDER.
# EXPORTS: mode, speed, target_path, wander_interval, arrival_distance, waypoints
# SIGNALS: waypoint_reached(index), target_reached(), direction_changed(dir)

extends CharacterBody2D

enum Mode { PATROL, CHASE, WANDER }

@export var mode: Mode = Mode.WANDER
@export var speed: float = 80.0
@export var target_path: NodePath = ^""
@export var wander_interval: float = 2.0
@export var arrival_distance: float = 8.0
@export var waypoints: Array[Vector2] = []

signal waypoint_reached(index: int)
signal target_reached()
signal direction_changed(dir: Vector2)

var _dir := Vector2.RIGHT
var _wp_index := 0
var _wander_timer := 0.0
var _target: Node2D = null

func _ready() -> void:
	if target_path != ^"":
		_target = get_node(target_path)

func _physics_process(delta: float) -> void:
	if mode == Mode.CHASE and _target:
		var d := _target.global_position - global_position
		if d.length() < arrival_distance:
			target_reached.emit()
		else:
			_set_dir(d.normalized())
	elif mode == Mode.PATROL and not waypoints.is_empty():
		var wp := to_global(waypoints[_wp_index])
		if global_position.distance_to(wp) < arrival_distance:
			waypoint_reached.emit(_wp_index)
			_wp_index = (_wp_index + 1) % waypoints.size()
		_set_dir((to_global(waypoints[_wp_index]) - global_position).normalized())
	elif mode == Mode.WANDER:
		_wander_timer -= delta
		if _wander_timer <= 0.0:
			_wander_timer = wander_interval
			_set_dir(Vector2.from_angle(randf() * TAU))
	velocity = _dir * speed
	move_and_slide()

func _set_dir(new_dir: Vector2) -> void:
	if new_dir != _dir:
		_dir = new_dir
		direction_changed.emit(_dir)
