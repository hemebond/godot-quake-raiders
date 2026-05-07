extends Node

@export var character: CharacterBody3D
@export var camera_holder: Node3D
@export var camera: Camera3D

@export var FOLLOW_SPEED : float = 16

func _ready() -> void:
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if camera_holder:
		camera.rotation.y = character.rotation.y
		camera.rotation.x = camera_holder.rotation.x

		camera.global_position.x = camera_holder.global_position.x
		camera.global_position.z = camera_holder.global_position.z

		# Because the camera lagged behind so much when falling
		# we just set the Y position directly instead of lerping
		# since the fall will be smooth anyway
		if camera_holder.global_position.y < camera.global_position.y:
			camera.global_position.y = camera_holder.global_position.y
		else:
			# frame-rate independant from https://docs.godotengine.org/en/4.4/tutorials/math/interpolation.html
			var weight = 1 - exp(-FOLLOW_SPEED * delta)
			camera.global_position.y = camera.global_position.lerp(camera_holder.global_position, weight).y
