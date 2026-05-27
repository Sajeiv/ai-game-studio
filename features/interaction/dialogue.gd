# FEATURE: dialogue
# STATUS: placeholder
# DESCRIPTION: Advances through an array of dialogue lines; emits finished when done.
# EXPORTS: lines (Array[String])
# DEPENDENCIES: attach to any Node; connect to a DialogueBox UI node

extends Node

@export var lines: Array[String] = []

var current_line: int = 0

signal line_changed(text: String)
signal finished

func start() -> void:
	current_line = 0
	if lines.is_empty():
		finished.emit()
		return
	line_changed.emit(lines[current_line])

func advance() -> void:
	current_line += 1
	if current_line >= lines.size():
		finished.emit()
	else:
		line_changed.emit(lines[current_line])
