# FEATURE: no_combat
# STATUS: verified
# DESCRIPTION: Explicit no-combat module. Disables all combat-related input actions.
# Use this when the game spec calls for a purely exploration or puzzle experience.
# EXPORTS: none
# DEPENDENCIES: none

extends Node

func _ready() -> void:
	# Intentionally empty — presence of this file signals to the Engineer
	# that no combat system should be wired into the scene.
	pass
