@tool
#extends StaticBody3D
extends AnimatableBody3D
class_name func_door



signal opening # also generic signal for this entity
signal closing



# TODO: Maybe try and rotate the object by the angle back to zero
# and then calculate the AABB so we can get the proper size
# of the mesh/bbox to use when moving

const SF_DONT_LINK = 2

@export var targetname:String
@export var spawnflags:int = 0
@export var angles:Vector3 = Vector3.ZERO
@export var angle:float = 0.0
@export var wait:float = 0.0
@export var lip:float = 8.0 / 32.0
@export var speed:float = 100 / 32.0
@export var sounds:int = 0


@onready var startPosition:Vector3
@onready var endPosition:Vector3

var LineDrawer:Node2D = preload("res://scripts/drawline3d.gd").new() #In 'global' scope

enum DoorState {
	CLOSED,
	CLOSING,
	OPEN,
	OPENING
}
var state:DoorState = DoorState.CLOSED

var aabb:AABB
var add:Vector3 = Vector3.ZERO
var add_reveal:Vector3
var dura:float
var tween:Tween
var player_end:bool = false
var open:bool = false

var has_crushed := false

@export_node_path("AnimationPlayer") var _animation_player: NodePath
@onready var animation_player: AnimationPlayer = get_node(_animation_player)

func _enter_tree() -> void:
	print("%s _enter_tree" % name)
	for c in get_children(true):
		print(c)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if targetname:
		print("Adding ", self, "to group", "T_" + targetname)
		add_to_group('T_' + targetname, true)

	for c in get_children(true):
		print("%s has child %s" % [name, c])



func _on_body_entered() -> void:
	print("body entered door ", name)



func create_trigger(_root_node: Node) -> void:
	# creating func_button area
	var area := Area3D.new()
	add_child(area)
	area.owner = _root_node  # have to set the owner to the scene root for it to show up in the Scene Tree
	#set_collision_layer_mask(area, ["func_button-areas"], ["func_button-characters"])
	#root_node.set("_area", root_node.get_path_to(area))
	
	for child in get_children():
		if child.is_class("CollisionShape3D"):
			var dupe := child.duplicate()
			area.add_child(dupe)
			dupe.owner = _root_node



func use(args:Array) -> void:
	var caller:Node3D = args[0]
	print("This is func_door.use() called by ", caller)
	_trigger(caller)



func set_import_value(key : String, value : String) -> bool:
	print("set_import_value: ", key, " = ", value)
	
	match key:
		"angle":
			angle = int(value)
			if int(value) == -1:
				angles = Vector3.UP
			elif int(value) == -2:
				angles = Vector3.DOWN
			else:
				var rads:float = deg_to_rad(int(value))
				angles = Vector3.RIGHT.rotated(Vector3.UP, rads)
			return true
		"wait":
			wait = int(value)
			return true
		"lip":
			lip = float(value) / 32
			return true
		"speed":
			speed = float(value) / 32
			return true

	return false



func touch(other:Node3D) -> void:
	_trigger(other)



func _trigger(_b:Node3D) -> void:
	print("_trigger()")
	print("animation_player.assigned_animation: ", animation_player.assigned_animation)

	# If we're part-way through an animation we need to know how far so we can start the opposite animation from that point
	var progress := 1.0 - animation_player.current_animation_position / animation_player.current_animation_length
		
	if animation_player.assigned_animation == "closed":
		animation_player.play("open")
		opening.emit()
	elif animation_player.assigned_animation == "close":
		animation_player.play("open")
		animation_player.seek(progress * animation_player.current_animation_length, true)
		opening.emit()
	elif animation_player.assigned_animation == "opened":
		animation_player.play("close")
		closing.emit()
	elif animation_player.assigned_animation == "open":
		animation_player.play("close")
		animation_player.seek(progress * animation_player.current_animation_length, true)
		closing.emit()



func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == "open":
		# checking if timer exists and disabling area forever otherwise
		# if is_instance_valid(wait_timer):
		# 	set_physics_process(true)
		# else:
		# 	area.monitoring = false
		animation_player.play("opened")
	elif animation_name == "close":
		animation_player.play("closed")
	# waiting for animation to finish before allowing to crush objects again
	has_crushed = false



func _gen_aabb() -> void:
	print(aabb)
	for m in get_children() :
		if m is CollisionShape3D :
			print(m)
			#aabb = aabb.merge(m.get_aabb())
			var shape := m.shape as ConvexPolygonShape3D

			if not shape:
				continue

			for points in shape.get_points():
				aabb = aabb.expand(points)
	print(aabb)



func _on_wait_timer_timeout() -> void:
	set_physics_process(false)
	#animation_player.play("close")
	#closing.emit()





func post_import(root_node: Node) -> void:
	print("%s.post_import()" % [name])
	print("root_node is %s" % root_node)

	add_to_group(&"doors", true)

	if true or not targetname:
		create_trigger(root_node)

	_gen_aabb()

	# creating func_door sound players
	var move_sound_player := AudioStreamPlayer3D.new()
	add_child(move_sound_player, true)
	move_sound_player.owner = root_node

	var stop_sound_player := AudioStreamPlayer3D.new()
	add_child(stop_sound_player, true)
	stop_sound_player.owner = root_node

	# loading func_door default sounds
	match sounds:
		0: # silent
			#move_sound_player.stream = null
			#stop_sound_player.stream = null
			move_sound_player.stream = preload("res://sounds/doors/doormv1.wav")
			stop_sound_player.stream = preload("res://sounds/doors/drclos4.wav")
		1: # stone
			move_sound_player.stream = preload("res://sounds/doors/doormv1.wav")
			stop_sound_player.stream = preload("res://sounds/doors/drclos4.wav")
		2: # machine
			move_sound_player.stream = preload("res://sounds/doors/basesec1.wav")
			stop_sound_player.stream = preload("res://sounds/doors/basesec2.wav")
		3: # stone chain
			move_sound_player.stream = preload("res://sounds/doors/stndr1.wav")
			stop_sound_player.stream = preload("res://sounds/doors/stndr2.wav")
		4: # screechy metal
			move_sound_player.stream = preload("res://sounds/doors/ddoor1.wav")
			stop_sound_player.stream = preload("res://sounds/doors/ddoor2.wav")

	# creating func_door animation player
	animation_player = AnimationPlayer.new()
	animation_player.playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_PHYSICS
	animation_player.animation_finished.connect(Callable(self, "_on_animation_finished"), CONNECT_PERSIST)
	add_child(animation_player, false, Node.INTERNAL_MODE_FRONT)
	set("_animation_player", get_path_to(animation_player))
	animation_player.owner = root_node

	# creating animations for func_door states
	var animations := _create_animations()

	var animation_library := AnimationLibrary.new()
	animation_library.add_animation("open", animations[0])
	animation_library.add_animation("opened", animations[1])
	animation_library.add_animation("close", animations[2])
	animation_library.add_animation("closed", animations[3])

	animation_player.add_animation_library("", animation_library)
	animation_player.autoplay = "closed"



func _create_animations() -> Array[Animation]:
	var inverse_transform:Transform3D = transform.affine_inverse()

	# creating empty animations
	var open_animation := Animation.new()
	var opened_animation := Animation.new()
	var close_animation := Animation.new()
	var closed_animation := Animation.new()
	open_animation.length = 0.0
	opened_animation.length = 0.0
	close_animation.length = 0.0
	closed_animation.length = 0.0

	var entity_center := aabb.get_center()

	# finding func_door sound players children
	var sound_players:Array[Node] = find_children("*", "AudioStreamPlayer3D", false, false)
	var move_sound_player: AudioStreamPlayer3D = sound_players[0]
	var stop_sound_player: AudioStreamPlayer3D = sound_players[1]

	# creating animation track names
	var door_track := "."
	var move_sound_playing_track := move_sound_player.name + ":playing"
	var stop_sound_playing_track := stop_sound_player.name + ":playing"

	open_animation.add_track(Animation.TYPE_POSITION_3D)
	open_animation.track_set_path(0, door_track)
	open_animation.add_track(Animation.TYPE_VALUE)
	open_animation.track_set_path(1, move_sound_playing_track)
	open_animation.add_track(Animation.TYPE_VALUE)
	open_animation.track_set_path(2, stop_sound_playing_track)

	opened_animation.add_track(Animation.TYPE_POSITION_3D)
	opened_animation.track_set_path(0, door_track)
	opened_animation.add_track(Animation.TYPE_VALUE)
	opened_animation.track_set_path(1, move_sound_playing_track)

	close_animation.add_track(Animation.TYPE_POSITION_3D)
	close_animation.track_set_path(0, door_track)
	close_animation.add_track(Animation.TYPE_VALUE)
	close_animation.track_set_path(1, move_sound_playing_track)
	close_animation.add_track(Animation.TYPE_VALUE)
	close_animation.track_set_path(2, stop_sound_playing_track)

	closed_animation.add_track(Animation.TYPE_POSITION_3D)
	closed_animation.track_set_path(0, door_track)
	closed_animation.add_track(Animation.TYPE_VALUE)
	closed_animation.track_set_path(1, move_sound_playing_track)

	# preparing to create animation key frames
	# var forward_axis := Vector3.ZERO
	# var local_forward_vector:Vector3 = -basis.z.normalized()
	# var forward_vector := local_forward_vector.normalized()
	# var forward_axis_index := forward_vector.abs().max_axis_index()
	# forward_axis[forward_axis_index] = signf(forward_vector[forward_axis_index])
	# var offset := clampf(aabb.size[forward_axis_index] - lip, 0.0, INF)
	# offset /= forward_vector.project(forward_axis).length()

	var rot := (angle / 180.0) * PI
	var dir := -(Vector3(
		aabb.size.x, 0.0, aabb.size.z
	)) + Vector3(lip, 0.0, lip)
	var offset := Vector3.BACK.rotated(Vector3.UP, rot) * dir

	print("%s aabb.size: %s" % [name, aabb.size])
	print("%s rot: %s" % [name, rot])
	print("%s dir: %s" % [name, dir])
	print("%s offset: %s" % [name, offset])

	# calculating func_door positions
	var door_close_position:Vector3 = position
	var door_open_position:Vector3 = position + offset

	# creating animation frame times
	var frames := [0.0, offset.length() / speed, offset.length() / speed + wait, 2.0 * offset.length() / speed + wait]
	print("frames: ", frames)
	print("offset: ", offset)
	print("lip: ", lip)
	print("speed: ", speed)

	if spawnflags & 1: # starts open
		var tmp := door_open_position
		door_open_position = door_close_position
		door_close_position = tmp

	# inserting keys into animations
	open_animation.length = maxf(open_animation.length, frames[1])
	open_animation.position_track_insert_key(0, frames[0], door_close_position)
	open_animation.track_insert_key(1, frames[0], true)
	open_animation.position_track_insert_key(0, frames[1], door_open_position)
	open_animation.track_insert_key(1, frames[1], false)
	open_animation.track_insert_key(2, frames[1], true)

	opened_animation.position_track_insert_key(0, frames[0], door_open_position)
	opened_animation.track_insert_key(1, frames[0], false)

	close_animation.length = maxf(close_animation.length, frames[1])
	close_animation.position_track_insert_key(0, frames[0], door_open_position)
	close_animation.track_insert_key(1, frames[0], true)
	close_animation.position_track_insert_key(0, frames[1], door_close_position)
	close_animation.track_insert_key(1, frames[1], false)
	close_animation.track_insert_key(2, frames[1], true)

	closed_animation.position_track_insert_key(0, frames[0], door_close_position)
	closed_animation.track_insert_key(1, frames[0], false)

	# finishing animation tracks
	open_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	open_animation.track_set_interpolation_loop_wrap(0, false)
	open_animation.track_set_imported(0, true)
	open_animation.value_track_set_update_mode(1, Animation.UPDATE_DISCRETE)
	open_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
	open_animation.track_set_interpolation_loop_wrap(1, false)
	open_animation.track_set_imported(1, true)
	open_animation.value_track_set_update_mode(2, Animation.UPDATE_DISCRETE)
	open_animation.track_set_interpolation_type(2, Animation.INTERPOLATION_NEAREST)
	open_animation.track_set_interpolation_loop_wrap(2, false)
	open_animation.track_set_imported(2, true)

	opened_animation.track_set_imported(0, true)
	opened_animation.track_set_imported(1, true)

	close_animation.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	close_animation.track_set_interpolation_loop_wrap(0, false)
	close_animation.track_set_imported(0, true)
	close_animation.value_track_set_update_mode(1, Animation.UPDATE_DISCRETE)
	close_animation.track_set_interpolation_type(1, Animation.INTERPOLATION_NEAREST)
	close_animation.track_set_interpolation_loop_wrap(1, false)
	close_animation.track_set_imported(1, true)
	close_animation.value_track_set_update_mode(2, Animation.UPDATE_DISCRETE)
	close_animation.track_set_interpolation_type(2, Animation.INTERPOLATION_NEAREST)
	close_animation.track_set_interpolation_loop_wrap(2, false)
	close_animation.track_set_imported(2, true)

	closed_animation.track_set_imported(0, true)
	closed_animation.track_set_imported(1, true)

	return [open_animation, opened_animation, close_animation, closed_animation]
