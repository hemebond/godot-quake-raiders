# https://github.com/Visssarion/Stairs-Stepping-Body/
extends CharacterBody3D
## CharacterBody3D that automatically controlls movement up and down the stairs

@export var input_synchronizer: MultiplayerSynchronizer



@export_category("Character's Collider")
## Collider that will be used for body's stair collision
@export var PLAYER_COLLIDER: CollisionShape3D

@export_category("Character Settings")
## Max height, in metres, the body can step up
@export var MAX_STEP_UP := 0.5
## Max height, in metres, the body will go down stairs
@export var MAX_STEP_DOWN := -0.5

@export_category("Debug Settings")
## Set to [code]true[/code] for body to print debug info for upward calculations
@export var STEP_DOWN_DEBUG := false
## Set to [code]true[/code] for body to print debug info for downward calculations
@export var STEP_UP_DEBUG := false







## Returns [code]true[/code] if body is grounded
var is_grounded := true

## Returns [code]true[/code] if body was grounded last physics frame
var was_grounded := true

## Calculated horizontal direction that body wants to move.[br]
## DO NOT USE THIS TO SET VELOCITY. Set [code]velocity[/code] instead.[br]
## [code]wish_dir[/code] is a left over from old implementation, so leaving it prevents stuff from breaking
var wish_dir := Vector3.ZERO			# Player input (WASD) direction

const vertical := Vector3(0, 1, 0)		# Shortcut for converting vectors to vertical
const horizontal := Vector3(1, 0, 1)		# Shortcut for converting vectors to horizontal

@export var speed: float = 10

const mouse_sens = 0.022 * 3.0

const unit_conversion = 32.0

const gravity = 800.0/unit_conversion
const jumpvel = 270.0/unit_conversion
const JUMP_VELOCITY = 270.0/unit_conversion

const max_speed = 320.0/unit_conversion
const max_speed_air = 320.0/unit_conversion

const accel = 15.0  # quake
const accel_air = 2.0

var friction = 6.0

# Quake 3 movement parameters
var pm_stopspeed : float = 100.0
var pm_duckScale : float = 0.25
var pm_swimScale : float = 0.50
var pm_wadeScale : float = 0.70

var pm_accelerate : float = 10.0
var pm_airaccelerate : float = 1.0
var pm_wateraccelerate : float = 4.0
var pm_flyaccelerate : float = 8.0

var pm_friction : float = 6.0
var pm_waterfriction : float = 1.0
var pm_flightfriction : float = 3.0
var pm_spectatorfriction : float = 5.0



@onready var camera: Camera3D = $camera_holder/camera
@onready var input: PlayerInput = $player_input


@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer
		$player_input.set_multiplayer_authority(id)
		$camera_holder.set_multiplayer_authority(id)
		$camera_holder/camera.set_multiplayer_authority(id)

func _ready() -> void:	
	if player == multiplayer.get_unique_id():
		camera.current = true

	print("Player %s is ready (authority %s)" % [multiplayer.get_unique_id(), get_multiplayer_authority()])

	# Set visibility of synchronizer to only send to the server
	#$player_input.set_visibility_for(1, true)
	
	# Disable processing, etc, for everyone except the authority
	#if not multiplayer.is_server():
		#set_process(false)
		#set_physics_process(false)




func _physics_process(delta: float) -> void:
	wish_dir = (transform.basis * Vector3(input.input_dir.x, 0, input.input_dir.y)).normalized()

	if is_on_floor():
		is_grounded = true
		if input.jumping:
			velocity.y = JUMP_VELOCITY
			input.jumping = false
	else:
		is_grounded = false
		velocity.y -= gravity * delta

	# Update player state
	was_grounded = is_grounded

	handle_friction(delta)
	handle_accel(delta)

	# Lock player collider rotation
	PLAYER_COLLIDER.global_rotation = Vector3.ZERO

	_post_physics_process.call_deferred()



# Some functions and code from "stair tester project"
# Other code from https://github.com/Visssarion/Stairs-Stepping-Body/

func _friction(_velocity : Vector3, delta : float) -> Vector3:
	_velocity *= pow(0.9, delta*60.0)
	if wish_dir == Vector3():
		_velocity = _velocity.move_toward(Vector3(), delta * max_speed)
	return _velocity



func handle_friction(delta):
	if is_on_floor():
		velocity = _friction(velocity, delta)



func handle_accel(delta):
	if wish_dir != Vector3.ZERO:
		var actual_maxspeed = max_speed if is_on_floor() else max_speed_air
		var wish_dir_length = wish_dir.length()
		var actual_accel = (accel if is_on_floor() else accel_air) * actual_maxspeed * wish_dir_length

		var floor_velocity = Vector3(velocity.x, 0, velocity.z)
		var speed_in_wish_dir = floor_velocity.dot(wish_dir.normalized())
		var speed = floor_velocity.length()
		if speed_in_wish_dir < actual_maxspeed:
			var add_limit = actual_maxspeed - speed_in_wish_dir
			var add_amount = min(add_limit, actual_accel*delta)
			velocity += wish_dir.normalized() * add_amount
			if is_on_floor() and speed > actual_maxspeed:
				velocity = velocity.normalized() * speed



# Function: Handle movement after velocity has been set
func _post_physics_process():
	stair_step_up()
	move_and_slide()
	stair_step_down()



# Function: Handle walking down stairs
func stair_step_down():
	if is_grounded:
		return

	# If we're falling from a step
	if velocity.y <= 0 and was_grounded:
		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true



# Function: Handle walking up stairs
func stair_step_up():
	if wish_dir == Vector3.ZERO:
		return

	if velocity.y > 0:
		return

	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = wish_dir * 0.1						## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())
	# _debug_stair_step_up("SSU_TEST_POS", test_transform)

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()

	if (snappedf(surface_normal.angle_to(vertical), 0.001) > floor_max_angle):
		return

	# 6. Move player up
	var global_pos = global_position
	var step_up_dist = test_transform.origin.y - global_pos.y

	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos
