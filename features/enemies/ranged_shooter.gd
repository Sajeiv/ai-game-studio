# FEATURE: ranged_shooter
# STATUS: placeholder
# DESCRIPTION: Enemy fires projectiles toward the player at a fixed interval.
# EXPORTS: fire_rate, bullet_speed, detection_radius
# DEPENDENCIES: CharacterBody2D, Timer, bullet scene

extends CharacterBody2D

@export var fire_rate: float = 2.0
@export var bullet_speed: float = 200.0
@export var detection_radius: float = 300.0
@export var bullet_scene: PackedScene

var target: Node2D = null
var timer: float = 0.0

func _physics_process(delta: float) -> void:
	if target == null:
		return
	timer += delta
	if timer >= fire_rate:
		timer = 0.0
		_shoot()

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (target.global_position - global_position).normalized()
	bullet.speed = bullet_speed
	get_parent().add_child(bullet)

func set_target(node: Node2D) -> void:
	target = node
