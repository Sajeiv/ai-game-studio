# FEATURE: locked_door
# STATUS: verified
# DESCRIPTION: Door that opens only when the player carries the matching key item.
# EXPORTS: required_key
# DEPENDENCIES: Area2D, inventory feature on player

extends Area2D

@export var required_key: String = "key"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_node("Inventory"):
		var inv: Node = body.get_node("Inventory")
		if inv.has_item(required_key):
			inv.remove_item(required_key)
			queue_free()
