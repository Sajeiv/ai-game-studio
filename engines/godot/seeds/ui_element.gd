# SEED: ui_element
# STATUS: verified
# DESCRIPTION: HUD control that displays a value as text, a progress bar, or an icon.
# EXPORTS: display_type, label_format, bar_color, max_value, icon_texture
# SIGNALS: display_updated(value)

extends Control

enum DisplayType { TEXT, BAR, ICON, COUNTER }

@export var display_type: DisplayType = DisplayType.TEXT
@export var label_format: String = "{value}"
@export var bar_color: Color = Color.GREEN
@export var max_value: float = 100.0
@export var icon_texture: Texture2D = null

signal display_updated(new_value: Variant)

var _label: Label
var _bar: ProgressBar
var _icon: TextureRect

func _ready() -> void:
	_label = Label.new()
	add_child(_label)
	_bar = ProgressBar.new()
	_bar.max_value = max_value
	_bar.add_theme_color_override("fill_color", bar_color)
	add_child(_bar)
	_icon = TextureRect.new()
	_icon.texture = icon_texture
	add_child(_icon)
	_refresh_visibility()

func set_value(v: Variant) -> void:
	display_updated.emit(v)
	match display_type:
		DisplayType.TEXT, DisplayType.COUNTER:
			_label.text = label_format.replace("{value}", str(v))
		DisplayType.BAR:
			_bar.value = float(v)
		DisplayType.ICON:
			_icon.visible = bool(v)

func _refresh_visibility() -> void:
	_label.visible = display_type in [DisplayType.TEXT, DisplayType.COUNTER]
	_bar.visible = display_type == DisplayType.BAR
	_icon.visible = display_type == DisplayType.ICON
