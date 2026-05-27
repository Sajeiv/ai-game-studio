# SEED: camera
# STATUS: verified
# DESCRIPTION: Smooth-follow camera with optional world-bounds clamping and zoom.
# EXPORTS: target_path, smoothing_speed, zoom_level, use_bounds, bounds_rect
# SIGNALS: zoom_changed(zoom), bounds_reached(side)

extends Camera2D

@export var target_path: NodePath = ^""
@export var smoothing_speed: float = 5.0
@export var zoom_level: Vector2 = Vector2.ONE
@export var use_bounds: bool = false
@export var bounds_rect: Rect2 = Rect2()

signal zoom_changed(zoom: Vector2)
signal bounds_reached(side: String)

var _target: Node2D = null

func _ready() -> void:
	if target_path != ^"":
		_target = get_node(target_path)
	zoom = zoom_level

func _process(delta: float) -> void:
	if _target == null:
		return
	var dest := _target.global_position
	if use_bounds:
		dest = dest.clamp(bounds_rect.position, bounds_rect.end)
	global_position = global_position.lerp(dest, smoothing_speed * delta)

func set_zoom_level(new_zoom: Vector2) -> void:
	zoom = new_zoom
	zoom_changed.emit(new_zoom)
