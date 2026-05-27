# FEATURE: melee_combat
# STATUS: placeholder
# DESCRIPTION: Hitbox-based melee attack with cooldown and knockback.
# EXPORTS: damage, attack_cooldown, knockback_force
# DEPENDENCIES: CharacterBody2D, Area2D hitbox child

extends Node

@export var damage: float = 10.0
@export var attack_cooldown: float = 0.5
@export var knockback_force: float = 200.0

var can_attack: bool = true

func attack(hitbox: Area2D) -> void:
	if not can_attack:
		return
	can_attack = false
	for body in hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
			_apply_knockback(body)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _apply_knockback(body: Node2D) -> void:
	if body is CharacterBody2D:
		var dir := (body.global_position - get_parent().global_position).normalized()
		body.velocity += dir * knockback_force
