extends MultiplayerSynchronizer

#
# Sends properties from client to server
#


@export var character: CharacterBody3D
@export var around: Node3D
@export var head: Node3D
@export var camera: Camera3D


var wishdir : Vector3 = Vector3()
var wish_jump : bool = false


func _ready() -> void:
	print("player_input ready: player %s, authority %s" % [
		get_multiplayer_authority(),
		multiplayer.get_unique_id()
	])
	# Only run process for the local player
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)


	
func _process(_delta: float) -> void:
	if not character:
		return

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED :
		return

	wishdir = (head if character.noclip else around).global_transform.basis * Vector3((
		Input.get_axis(&"q1_move_left", &"q1_move_right")
	), 0, (
		Input.get_axis(&"q1_move_forward", &"q1_move_back")
	)).normalized()

	if character.noclip:
		return

	if character.auto_jump :
		wish_jump = Input.is_action_pressed(&"q1_jump")
	else :
		if !wish_jump and Input.is_action_just_pressed(&"q1_jump") :
			wish_jump = true
		if Input.is_action_just_released(&"q1_jump") :
			wish_jump = false



func _input(event : InputEvent) -> void :
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED :
		return

	if Input.is_action_just_pressed(&'q1_toggle_noclip') :
		toggle_noclip()

	if event is InputEventMouseMotion :
		var r : Vector2 = event.relative * -1
		#head.rotate_x(r.y * character.sensitivity)
		#around.rotate_y(r.x * character.sensitivity)
		#head.rotation.x = clampf(head.rotation.x, -PI/2, PI/2)
		
		head.rotate_y(r.x * character.sensitivity)
		camera.rotate_x(r.y * character.sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -PI/2, PI/2)



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("m1"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("m2"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



func toggle_noclip() -> void:
	character.noclip = !character.noclip
