# FEATURE: scene_transition
# STATUS: placeholder
# DESCRIPTION: Fade-to-black transition between scenes using an AnimationPlayer.
# EXPORTS: transition_duration
# DEPENDENCIES: CanvasLayer, ColorRect covering the screen, AnimationPlayer

extends CanvasLayer

@export var transition_duration: float = 0.5

@onready var anim: AnimationPlayer = $AnimationPlayer

func transition_to(scene_path: String) -> void:
	anim.play("fade_out")
	await anim.animation_finished
	get_tree().change_scene_to_file(scene_path)
	anim.play("fade_in")
