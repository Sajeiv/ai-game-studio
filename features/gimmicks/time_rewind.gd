# FEATURE: time_rewind
# STATUS: placeholder
# DESCRIPTION: Records position history and rewinds the player backward when the rewind key is held.
# EXPORTS: rewind_key, history_seconds, record_interval
# DEPENDENCIES: Node2D (attach to player)

extends Node

@export var rewind_key: String = "rewind"
@export var history_seconds: float = 5.0
@export var record_interval: float = 0.05

var history: Array[Vector2] = []
var record_timer: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_pressed(rewind_key):
		_rewind()
	else:
		_record(delta)

func _record(delta: float) -> void:
	record_timer += delta
	if record_timer < record_interval:
		return
	record_timer = 0.0
	history.append(get_parent().global_position)
	var max_frames := int(history_seconds / record_interval)
	if history.size() > max_frames:
		history.pop_front()

func _rewind() -> void:
	if history.is_empty():
		return
	get_parent().global_position = history.pop_back()
