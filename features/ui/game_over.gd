# FEATURE: game_over
# STATUS: verified
# DESCRIPTION: Game Over screen shown when the player dies. Restart reloads current scene.
# EXPORTS: none
# DEPENDENCIES: CanvasLayer; call show_screen() to display

extends CanvasLayer

func _ready() -> void:
	hide()

func show_screen() -> void:
	show()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
