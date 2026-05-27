# FEATURE: dialogue_box
# STATUS: placeholder
# DESCRIPTION: UI panel that displays one line of dialogue at a time with a typewriter effect.
# EXPORTS: typewriter_speed
# DEPENDENCIES: CanvasLayer, RichTextLabel, Button (next)

extends CanvasLayer

@export var typewriter_speed: float = 0.03

@onready var text_label: RichTextLabel = $Panel/Text
@onready var next_button: Button = $Panel/NextButton

signal next_pressed

func _ready() -> void:
	hide()
	next_button.pressed.connect(func(): next_pressed.emit())

func show_line(text: String) -> void:
	show()
	text_label.text = ""
	for ch in text:
		text_label.text += ch
		await get_tree().create_timer(typewriter_speed).timeout

func hide_box() -> void:
	hide()
