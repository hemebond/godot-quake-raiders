extends Node

@export var character: CharacterBody3D
#@export var JUMP_VELOCITY := 12.0		# Player's jump velocity.

const unit_conversion = 32.0
const JUMP_VELOCITY = 270.0/unit_conversion

func _physics_process(_delta: float) -> void:
	# Handle Jump
	if character.is_grounded and Input.is_action_pressed("move_jump"):
	#if character.is_grounded and Input.is_action_pressed("ui_accept"):
		character.velocity.y = JUMP_VELOCITY
