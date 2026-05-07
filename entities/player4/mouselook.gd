extends Node

@export var character: CharacterBody3D
@export var camera_holder: Node3D

var mouse_sensitivity: float = 0.1



#func _input(event: InputEvent) -> void:	
	#if event is InputEventMouseMotion:
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#character.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			#camera_holder.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			#camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad(-89), deg_to_rad(89))
#
#
#func _unhandled_input(event: InputEvent) -> void:	
	#if event.is_action_pressed("m1") or event.is_action_pressed("m2"):
		#if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
