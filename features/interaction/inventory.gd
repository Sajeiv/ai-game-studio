# FEATURE: inventory
# STATUS: verified
# DESCRIPTION: Array-backed inventory with add, remove, and has_item methods.
# EXPORTS: capacity
# DEPENDENCIES: none (attach to any Node)

extends Node

@export var capacity: int = 16

var items: Array[String] = []

signal item_added(item_name: String)
signal item_removed(item_name: String)

func add_item(item_name: String) -> bool:
	if items.size() >= capacity:
		return false
	items.append(item_name)
	item_added.emit(item_name)
	return true

func remove_item(item_name: String) -> bool:
	var idx := items.find(item_name)
	if idx == -1:
		return false
	items.remove_at(idx)
	item_removed.emit(item_name)
	return true

func has_item(item_name: String) -> bool:
	return items.has(item_name)
