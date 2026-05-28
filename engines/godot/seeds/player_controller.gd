# SEED: player_controller
# STATUS: verified
# DESCRIPTION: Reads player input, moves a CharacterBody2D, drives AnimatedSprite2D.
#              Animation: _physics_process reads input directly, play() called only on
#              animation name change. Override _build_frames() with game-specific paths.
# EXPORTS: speed, input_left, input_right, input_up, input_down
# SIGNALS: moved(direction), stopped()

extends CharacterBody2D

@export var speed: float = 150.0
@export var input_left:  StringName = &"ui_left"
@export var input_right: StringName = &"ui_right"
@export var input_up:    StringName = &"ui_up"
@export var input_down:  StringName = &"ui_down"

signal moved(direction: Vector2)
signal stopped()

const _FPS := 8
@onready var _body: AnimatedSprite2D = $Body
var _was_moving := false
var _last_anim  := ""

func _ready() -> void:
	_body.sprite_frames = _build_frames()

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector(input_left, input_right, input_up, input_down)
	velocity = dir * speed
	move_and_slide()
	if dir != Vector2.ZERO:
		_was_moving = true
		moved.emit(dir)
	elif _was_moving:
		_was_moving = false
		stopped.emit()
	_update_anim()

func _update_anim() -> void:
	var anim := "idle"
	if velocity != Vector2.ZERO:
		if abs(velocity.x) >= abs(velocity.y):
			anim = "walk_right" if velocity.x > 0 else "walk_left"
		else:
			anim = "walk_down" if velocity.y > 0 else "walk_up"
	if anim != _last_anim:
		_last_anim = anim
		_body.play(anim)

# Override this in the game to return a SpriteFrames with:
#   idle (1 frame, no loop), walk_down/up/left/right (4 frames each, loop)
func _build_frames() -> SpriteFrames:
	return SpriteFrames.new()

func _add(sf: SpriteFrames, name: String, loop: bool, paths: Array) -> void:
	sf.add_animation(name)
	sf.set_animation_loop(name, loop)
	sf.set_animation_speed(name, _FPS)
	for p in paths:
		sf.add_frame(name, load(p))
