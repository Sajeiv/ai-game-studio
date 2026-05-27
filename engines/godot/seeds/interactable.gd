# SEED: interactable
# STATUS: verified
# DESCRIPTION: Shows a prompt label and emits a signal when the player interacts nearby.
# EXPORTS: prompt_text, interact_action, one_shot, interaction_radius
# SIGNALS: interacted(interactor), player_entered_range(), player_exited_range()

extends Area2D

@export var prompt_text: String = "Press E"
@export var interact_action: StringName = &"interact"
@export var one_shot: bool = false
@export var interaction_radius: float = 48.0

signal interacted(interactor: Node)
signal player_entered_range()
signal player_exited_range()

var _player_in_range: Node = null
var _prompt: Label

func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = interaction_radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	_prompt = Label.new()
	_prompt.text = prompt_text
	_prompt.position = Vector2(-20.0, -44.0)
	_prompt.visible = false
	add_child(_prompt)
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed(interact_action):
		interacted.emit(_player_in_range)
		if one_shot:
			_prompt.visible = false
			set_process_unhandled_input(false)

func _on_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = body
		_prompt.visible = true
		player_entered_range.emit()

func _on_exited(body: Node) -> void:
	if body == _player_in_range:
		_player_in_range = null
		_prompt.visible = false
		player_exited_range.emit()
