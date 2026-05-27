# FEATURE: intro_screen
# STATUS: verified
# DESCRIPTION: Title / intro screen shown before gameplay starts.
# EXPORTS: game_scene_path
# DEPENDENCIES: CanvasLayer

extends CanvasLayer

@export var game_scene_path: String = ""

func _on_start_pressed() -> void:
	if game_scene_path != "":
		get_tree().change_scene_to_file(game_scene_path)
