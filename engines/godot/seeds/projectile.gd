# SEED: projectile
# STATUS: verified
# DESCRIPTION: Moves in a direction at constant speed, destroys on collision or max range.
# EXPORTS: speed, direction, max_range, pierce_count
# SIGNALS: hit(target, position), max_range_reached(), destroyed()

extends Area2D

@export var speed: float = 300.0
@export var direction: Vector2 = Vector2.RIGHT
@export var max_range: float = 400.0
@export var pierce_count: int = 0

signal hit(target: Node, hit_position: Vector2)
signal max_range_reached()
signal destroyed()

var _distance_traveled: float = 0.0
var _hits_left: int = 0

func _ready() -> void:
	_hits_left = pierce_count
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	var step := direction.normalized() * speed * delta
	position += step
	_distance_traveled += step.length()
	if max_range > 0.0 and _distance_traveled >= max_range:
		max_range_reached.emit()
		_destroy()

func _on_body_entered(body: Node) -> void:
	hit.emit(body, global_position)
	if _hits_left <= 0:
		_destroy()
	else:
		_hits_left -= 1

func _destroy() -> void:
	destroyed.emit()
	queue_free()
