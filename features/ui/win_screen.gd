# FEATURE: win_screen
# STATUS: verified
# DESCRIPTION: Win screen shown when the player completes the objective.
# EXPORTS: next_scene_path
# DEPENDENCIES: CanvasLayer; call show_screen() to display

extends CanvasLayer

@export var next_scene_path: String = ""

func _ready() -> void:
	hide()

func show_screen() -> void:
	show()

func _on_continue_pressed() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		get_tree().reload_current_scene()
