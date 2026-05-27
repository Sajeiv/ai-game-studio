# SEED: dialogue
# STATUS: verified
# DESCRIPTION: Shows dialogue lines one at a time with typewriter effect, advances on key press.
# EXPORTS: advance_action, typewriter_speed
# SIGNALS: dialogue_started(), line_shown(index, text), dialogue_finished()

extends CanvasLayer

@export var advance_action: StringName = &"interact"
@export var typewriter_speed: float = 30.0

signal dialogue_started()
signal line_shown(index: int, text: String)
signal dialogue_finished()

var _lines: Array = []
var _index: int = 0
var _typing: bool = false
var _full_text: String = ""
var _label: RichTextLabel
var _panel: PanelContainer
var _tween: Tween

func _ready() -> void:
	_panel = PanelContainer.new()
	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.custom_minimum_size = Vector2(600, 80)
	_panel.add_child(_label)
	add_child(_panel)
	_panel.visible = false

func start(lines: Array) -> void:
	_lines = lines
	_index = 0
	_panel.visible = true
	dialogue_started.emit()
	_show_line(0)

func _show_line(i: int) -> void:
	_full_text = _lines[i].get("text", "")
	line_shown.emit(i, _full_text)
	if typewriter_speed <= 0.0:
		_label.text = _full_text
		return
	_label.text = ""
	_typing = true
	_tween = create_tween()
	_tween.tween_method(func(n: int): _label.text = _full_text.left(n), 0, _full_text.length(), _full_text.length() / typewriter_speed)
	_tween.finished.connect(func(): _typing = false)

func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible or not event.is_action_pressed(advance_action):
		return
	if _typing:
		if _tween: _tween.kill()
		_label.text = _full_text
		_typing = false
		return
	_index += 1
	if _index >= _lines.size():
		_panel.visible = false
		dialogue_finished.emit()
	else:
		_show_line(_index)
