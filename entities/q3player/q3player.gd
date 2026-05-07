extends Node3D


var SCALER : float = 1/32  # convert Quake units to Godot

var STEPSIZE := 18 * SCALER
var JUMP_VELOCITY := 270 * SCALER
var TIMER_LAND := 130
var TIMER_GESTURE = (34 * 66 + 50)
var OVERCLIP := 1.001



var waterlevel = 0
var walking = false
var spectator = false

# Should these use SCALER? Who knows
var pm_stopspeed := 100.0 * SCALER
var pm_duckscale := 0.25 * SCALER
var pm_swimscale := 0.5 * SCALER

# SHould _these_ use SCALER?
var pm_friction := 6.0
var pm_waterfriction := 1.0
var pm_flightfriction := 3.0
var pm_spectatorfriction := 5.0


enum MoveType {
	Crouch,
	Walk,
	Run
}


var wishRestart = false
var wishJump = false
var wishSink = false
var wishFire = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func pm_friction(delta : float) -> void:
	var vec : Vector3
	var vel : float
	var speed : float
	var newspeed : float
	var control : float
	var drop : float

	vel = velocity
	vec = vel

	if walking:
		vec.y = 0  # ignore slope movement

	speed = vec.length
	if speed < 1:
		vel.x = 0
		vel.z = 0
		return

	drop = 0

	if waterlevel <= 1:
		if walking:  # && surface is _not_ slick
			control = pm_stopspeed if speed < stopspeed else speed
			drop += control * pm_friction * delta

	# apply water friction even if just wading
	if waterlevel:
		drop += speed * pm_waterfriction * waterlevel * delta


	if spectator:
		drop += speed * pm_spectatorfriction * delta

	newspeed = speed - drop
	if newspeed < 0:
		newspeed = 0

	newspeed /= speed

	vel.x = vel.x * newspeed
	vel.z = vel.z * newspeed
	vel.y = vel.y * newspeed



func pm_accelerate(wishdir : Vector3, wishspeed : float, accel : float, delta : float) -> void:
	var i : int
	var addspeed : float
	var accelspeed : float
	var currentspeed : float

	currentspeed = velocity.dot(wishdir)

	addspeed = wishspeed - currentspeed
	if addspeed <= 0:
		return

	accelspeed = accel * delta * wishspeed
	if accelspeed > addspeed:
		accelspeed = addspeed

	velocity.x += accelspeed * wishdir.x
	velocity.z += accelspeed * wishdir.z
	velocity.y += accelspeed * wishdir.y



func pm_walkmove() -> void:
	var i : int
	var wishvel : Vector3
	var fmove : float
	var smove : float
	var wishdir : Vector3
	var wishspeed : float
	var scale : float
	var accelerate : float
	var vel : float

	# pm_watermove()

	# if pm_checkjump():
	# 	if waterlevel > 1:
	# 		pm_watermove()
	# 	else:
	# 		pm_airmove()
	# 	return

	# pm_friction()

	# pm_setmovementdir()

	# pm_clipvelocity(forward, ...)
	# pm_clipvelocity(right, ...)
