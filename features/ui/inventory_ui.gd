# FEATURE: inventory_ui
# STATUS: placeholder
# DESCRIPTION: Grid-based inventory panel toggled by a key press.
# EXPORTS: toggle_key, columns
# DEPENDENCIES: CanvasLayer, GridContainer; inventory feature on player

extends CanvasLayer

@export var toggle_key: String = "ui_inventory"
@export var columns: int = 4

@onready var grid: GridContainer = $Panel/Grid

func _ready() -> void:
	grid.columns = columns
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_just_pressed(toggle_key):
		visible = !visible
		if visible:
			_refresh()

func _refresh() -> void:
	for child in grid.get_children():
		child.queue_free()
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var inv: Node = players[0].get_node_or_null("Inventory")
	if inv == null:
		return
	for item in inv.items:
		var label := Label.new()
		label.text = item
		grid.add_child(label)
