# FEATURE: pickup_item
# STATUS: verified
# DESCRIPTION: Collectible item that adds itself to the player inventory on contact.
# EXPORTS: item_name
# DEPENDENCIES: Area2D, inventory feature on player

extends Area2D

@export var item_name: String = "item"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_node("Inventory"):
		var inv: Node = body.get_node("Inventory")
		if inv.add_item(item_name):
			queue_free()
