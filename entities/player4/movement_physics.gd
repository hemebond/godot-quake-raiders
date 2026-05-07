extends Node

@export var character: StairsCharacterBody3D

var wish_dir := Vector3()

const unit_conversion = 32.0

const max_speed = 320.0/unit_conversion
const max_speed_air = 320.0/unit_conversion

const accel = 15.0
const accel_air = 2.0

var friction = 6.0


# Some functions and code from "stair tester project"
# Other code from https://github.com/Visssarion/Stairs-Stepping-Body/

func is_on_floor():
	return character.is_on_floor()


func _friction(_velocity : Vector3, delta : float) -> Vector3:
	_velocity *= pow(0.9, delta*60.0)
	if wish_dir == Vector3():
		_velocity = _velocity.move_toward(Vector3(), delta * max_speed)
	return _velocity



func handle_friction(delta):
	if is_on_floor():
		character.velocity = _friction(character.velocity, delta)



func handle_accel(delta):
	if wish_dir != Vector3():
		var actual_maxspeed = max_speed if is_on_floor() else max_speed_air
		var wish_dir_length = wish_dir.length()
		var actual_accel = (accel if is_on_floor() else accel_air) * actual_maxspeed * wish_dir_length

		var floor_velocity = Vector3(character.velocity.x, 0, character.velocity.z)
		var speed_in_wish_dir = floor_velocity.dot(wish_dir.normalized())
		var speed = floor_velocity.length()
		if speed_in_wish_dir < actual_maxspeed:
			var add_limit = actual_maxspeed - speed_in_wish_dir
			var add_amount = min(add_limit, actual_accel*delta)
			character.velocity += wish_dir.normalized() * add_amount
			if is_on_floor() and speed > actual_maxspeed:
				character.velocity = character.velocity.normalized() * speed



func handle_friction_and_accel(delta):
	handle_friction(delta)
	handle_accel(delta)



func _physics_process(delta: float) -> void:
	#print("I am player %s" % multiplayer.get_unique_id())
	if not is_multiplayer_authority():
		#print("I am not the authority")
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = (character.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	handle_friction_and_accel(delta)
