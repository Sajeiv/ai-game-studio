# SEED: scene_manager
# STATUS: verified
# DESCRIPTION: Singleton — transitions between scenes with a black fade overlay.
# EXPORTS: transition_duration
# SIGNALS: transition_started(to_scene), transition_finished(to_scene)
# NOTE: Register as autoload named SceneManager in Project Settings.

extends Node

@export var transition_duration: float = 0.4

signal transition_started(to_scene: String)
signal transition_finished(to_scene: String)

var _overlay: ColorRect

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_overlay = ColorRect.new()
	_overlay.color = Color.BLACK
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.modulate.a = 0.0
	layer.add_child(_overlay)

func go_to(path: String, _payload: Dictionary = {}) -> void:
	transition_started.emit(path)
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, transition_duration)
	await tween.finished
	get_tree().change_scene_to_file(path)
	tween = create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, transition_duration)
	await tween.finished
	transition_finished.emit(path)
