# FEATURE: hud
# STATUS: verified
# DESCRIPTION: In-game HUD that displays health and item count from player nodes.
# EXPORTS: none
# DEPENDENCIES: CanvasLayer; expects player group with health + inventory

extends CanvasLayer

@onready var health_label: Label = $HealthLabel
@onready var item_label: Label = $ItemLabel

func _process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player := players[0]
	if player.has_node("Health"):
		health_label.text = "HP: %d" % player.get_node("Health").current
	if player.has_node("Inventory"):
		item_label.text = "Items: %d" % player.get_node("Inventory").items.size()
