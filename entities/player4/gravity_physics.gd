extends Node

@export var character: CharacterBody3D

#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const unit_conversion = 32.0
const gravity = 800.0/unit_conversion

func _physics_process(delta: float) -> void:
	if not character.is_grounded:
		character.velocity.y -= gravity * delta
