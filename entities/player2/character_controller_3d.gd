extends CharacterBody3D
class_name  CharacterController3D



const gravity : int = 800
const stopspeed : int = 100
const maxspeed : int = 320
const accelerate : int = 100
const airaccelerate : float = 0.7
const wateraccelerate : float = 10.0
const friction : float = 4
const waterfriction : float = 4

var water_level : int = 0

var input_dir : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_movement(delta)


@export var movement_speed := maxspeed

func process_movement(delta: float):
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var wish_dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, $CameraHolder.global_rotation.y)
	velocity = wish_dir * movement_speed
	var old_velocity : Vector3 = velocity

	
	velocity = Vector3.UP * 16
	move_and_collide()
	
	velocity = wish_dir * delta * movement_speed
	print("Move up: ", velocity)
	move_and_collide()

	velocity = Vector3.DOWN * 16
	move_and_collide()

	velocity.y -= gravity * delta * 0.5
	move_and_collide()
	
