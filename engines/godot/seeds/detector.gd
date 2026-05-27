# SEED: detector
# STATUS: verified
# DESCRIPTION: Detects targets by area overlap or distance proximity. Emits signals only.
# EXPORTS: mode, detection_radius, target_group, check_interval
# SIGNALS: target_detected(target), target_lost(target), target_in_range(target, distance)

extends Node2D

enum Mode { AREA, PROXIMITY }

@export var mode: Mode = Mode.AREA
@export var detection_radius: float = 150.0
@export var target_group: StringName = &"player"
@export var check_interval: float = 0.1

signal target_detected(target: Node)
signal target_lost(target: Node)
signal target_in_range(target: Node, distance: float)

var _detected: Array[Node] = []
var _timer: float = 0.0

func _ready() -> void:
	if mode == Mode.AREA:
		var area := Area2D.new()
		var shape := CircleShape2D.new()
		shape.radius = detection_radius
		var col := CollisionShape2D.new()
		col.shape = shape
		area.add_child(col)
		add_child(area)
		area.body_entered.connect(_on_entered)
		area.body_exited.connect(_on_exited)

func _physics_process(delta: float) -> void:
	if mode != Mode.PROXIMITY:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = check_interval
	for node in get_tree().get_nodes_in_group(target_group):
		var dist := global_position.distance_to(node.global_position)
		if dist <= detection_radius:
			target_in_range.emit(node, dist)
			if node not in _detected:
				_detected.append(node)
				target_detected.emit(node)
		elif node in _detected:
			_detected.erase(node)
			target_lost.emit(node)

func _on_entered(body: Node) -> void:
	if body.is_in_group(target_group) and body not in _detected:
		_detected.append(body)
		target_detected.emit(body)

func _on_exited(body: Node) -> void:
	if body in _detected:
		_detected.erase(body)
		target_lost.emit(body)
