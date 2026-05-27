# FEATURE: health_bar
# STATUS: placeholder
# DESCRIPTION: Progress bar that tracks a Health node on the parent or a target node.
# EXPORTS: target_path
# DEPENDENCIES: ProgressBar (or TextureProgressBar); Health node on target

extends ProgressBar

@export var target_path: NodePath = NodePath("")

func _ready() -> void:
	min_value = 0.0

func _process(_delta: float) -> void:
	var target: Node = get_node_or_null(target_path)
	if target == null:
		return
	if target.has_node("Health"):
		var h: Node = target.get_node("Health")
		max_value = h.max_health
		value = h.current
