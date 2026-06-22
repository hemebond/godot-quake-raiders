@tool
extends Node3D


@onready var mesh:MeshInstance3D = $mesh
var on:bool = false
var current_frame:int = 0

var animation_list = []
var current_animation:String = "stand"
var animations := {}

@export var animation_frame:int = 0
var previous_animation_frame:int = 0
var next_animation_frame:int = 0

@export var animation_player:AnimationPlayer

#@export_tool_button("Update animation player", "Callable") var update_animation_button = _update_animation_player
@export_tool_button("Update animation player")
var update_animation_button:
	get:
		return _update_animation_player
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (animation_frame != previous_animation_frame):
		mesh.set_blend_shape_value(previous_animation_frame, 0.0)
		previous_animation_frame = animation_frame
		
	mesh.set_blend_shape_value(animation_frame, 1.0)



func _update_animation_player() -> void:
	var animation_library:AnimationLibrary = animation_player.get_animation_library("")

	var initial_animation_list := animation_player.get_animation_list()
	var a = animation_player.get_animation("standtest")
	for i in range(a.get_track_count()):
		print(a)
		print(a.track_get_path(i))
	
	
	var regex:RegEx = RegEx.create_from_string("([a-z]+)")
	
	var arrmesh:ArrayMesh = mesh.mesh
	var shape_name:String
	var animation_name:String
	
	for i in range(mesh.get_blend_shape_count()):
		shape_name = arrmesh.get_blend_shape_name(i)
		animation_name = regex.search(shape_name).strings[0]
		
		if animation_name not in animations.keys():
			animations[animation_name] = {
				"start": i,
				"end": i
			}
		else:
			animations[animation_name].end = i
	
	print(animations)

	animation_name = "stand"
	var frame:int = 0
	var animation_start:int = mesh.find_blend_shape_by_name(animation_name + str(1))
	var animation_end:int = animation_start
	
	for i in range(2, mesh.get_blend_shape_count()):
		frame = mesh.find_blend_shape_by_name(animation_name + str(i))
		if frame == -1:
			break
		else:
			animation_end = frame
	
	print("start: ", animation_start)
	print("end: ", animation_end)
	animations[animation_name] = {
		"start": animation_start,
		"end": animation_end
	}
	print(animations)
	
	for ani_name in animations:
		var ani = animations[ani_name]
		var animation_length:int = ani.end - ani.start + 1

		var animation := Animation.new()
		animation.length = 0.1 * animation_length
		var track_index := animation.add_track(Animation.TYPE_VALUE)
		
		for i in range(animation_length):
			animation.track_set_path(track_index, ".:animation_frame")
			animation.track_insert_key(track_index, 0.1 * i, ani.start + i)
		animation.track_insert_key(track_index, 0.1 * animation_length, ani.start)
		animation_library.add_animation(ani_name, animation)
	
