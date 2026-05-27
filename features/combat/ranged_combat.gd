# FEATURE: ranged_combat
# STATUS: placeholder
# DESCRIPTION: Player fires projectiles toward the mouse cursor on attack input.
# EXPORTS: bullet_scene, fire_rate, bullet_speed
# DEPENDENCIES: Node2D, bullet scene with direction + speed properties

extends Node

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
@export var bullet_speed: float = 400.0

var can_fire: bool = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_just_pressed("attack") and can_fire:
		_fire()

func _fire() -> void:
	if bullet_scene == null:
		return
	can_fire = false
	var parent := get_parent()
	var bullet := bullet_scene.instantiate()
	bullet.global_position = parent.global_position
	bullet.direction = (parent.get_global_mouse_position() - parent.global_position).normalized()
	bullet.speed = bullet_speed
	parent.get_parent().add_child(bullet)
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true
