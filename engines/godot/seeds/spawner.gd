# SEED: spawner
# STATUS: verified
# DESCRIPTION: Instantiates a PackedScene on a timer or on demand, with an optional pool cap.
# EXPORTS: scene_to_spawn, spawn_mode, spawn_interval, max_instances, spawn_positions
# SIGNALS: spawned(instance), pool_full(), instance_freed(instance)

extends Node2D

enum SpawnMode { TIMER, ON_DEMAND }

@export var scene_to_spawn: PackedScene = null
@export var spawn_mode: SpawnMode = SpawnMode.TIMER
@export var spawn_interval: float = 3.0
@export var max_instances: int = 0
@export var spawn_positions: Array[Vector2] = []

signal spawned(instance: Node)
signal pool_full()
signal instance_freed(instance: Node)

var _instances: Array[Node] = []
var _timer: float = 0.0

func _process(delta: float) -> void:
	if spawn_mode != SpawnMode.TIMER:
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		spawn()

func spawn() -> Node:
	_instances = _instances.filter(func(n): return is_instance_valid(n))
	if max_instances > 0 and _instances.size() >= max_instances:
		pool_full.emit()
		return null
	if scene_to_spawn == null:
		return null
	var inst := scene_to_spawn.instantiate()
	get_parent().add_child(inst)
	inst.global_position = to_global(spawn_positions.pick_random()) if not spawn_positions.is_empty() else global_position
	_instances.append(inst)
	spawned.emit(inst)
	if inst.has_signal("tree_exiting"):
		inst.tree_exiting.connect(func(): instance_freed.emit(inst))
	return inst

func set_interval(interval: float) -> void:
	spawn_interval = interval
	_timer = minf(_timer, interval)
