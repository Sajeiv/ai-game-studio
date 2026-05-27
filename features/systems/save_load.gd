# FEATURE: save_load
# STATUS: placeholder
# DESCRIPTION: Saves and loads a Dictionary of game state to a local file via FileAccess.
# EXPORTS: save_path (relative to user://)
# DEPENDENCIES: none

extends Node

@export var save_path: String = "savegame.json"

func save(data: Dictionary) -> void:
	var file := FileAccess.open("user://" + save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_data() -> Dictionary:
	var full_path := "user://" + save_path
	if not FileAccess.file_exists(full_path):
		return {}
	var file := FileAccess.open(full_path, FileAccess.READ)
	var result := JSON.parse_string(file.get_as_text())
	return result if result is Dictionary else {}
