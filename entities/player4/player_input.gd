class_name PlayerInput
extends MultiplayerSynchronizer


@export var character: CharacterBody3D
@export var camera_holder: Node3D
@export var camera: Camera3D


@export var input_dir: Vector2
@export var look_dir: Vector3 = Vector3.ZERO
var mouse_sensitivity: float = 0.1
@export var jumping := false


func _ready() -> void:
	print("player_input ready: player %s, authority %s" % [
		get_multiplayer_authority(),
		multiplayer.get_unique_id()
	])
	# Only run process for the local player
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump() -> void:
	jumping = true
	
func _process(delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			character.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			#look_dir.rotated(Vector3.UP, deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera_holder.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			#look_dir.rotated(Vector3.RIGHT, deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera_holder.rotation.x = clamp(camera_holder.rotation.x, deg_to_rad(-89), deg_to_rad(89))
			print(character.rotation)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("m1"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("m2"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
