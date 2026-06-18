@tool
#extends StaticBody3D
extends AnimatableBody3D
class_name func_door

const SF_DONT_LINK = 2

@export var targetname:String
@export var spawnflags:int = 0
@export var angles:Vector3 = Vector3.ZERO
@export var angle:int = 0
@export var wait:int = 0
@export var lip:float = 8.0 / 32.0
@export var speed:int = 100


@onready var startPosition:Vector3
@onready var endPosition:Vector3

#var LineDrawer:Node2D = preload("res://scripts/drawline3d.gd").new() #In 'global' scope

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if targetname:
		print("Adding ", self, "to group", "T_" + targetname)
		add_to_group('T_' + targetname, true)
	
	_calc_add()
	
	startPosition = position
	endPosition = startPosition + add
	
	print("add: ", add)
	print("startPosition: ", startPosition)
	print("endPosition: ", endPosition)



func _on_body_entered() -> void:
	print("body entered door ", name)



func post_import(_root_node: Node) -> void:
	print("%s.post_import()" % [name])
	
	add_to_group(&"doors", true)
	if not targetname:
		create_trigger(_root_node)



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
			speed = int(value)

	return false



func touch(other:Node3D) -> void:
	_trigger(other)



func _trigger(_b:Node3D) -> void:
	print("_trigger()")

	if tween : return
	_move()
	#for l in links :
		#l._trigger(b)


func _gen_aabb() -> void:
	for m in get_children() :
		if m is GeometryInstance3D :
			aabb = aabb.merge(m.get_aabb())



func _calc_add() -> void:
	# func_door5 has angle 0
	# this means positive x axis
	# in godot this is -z axis
	# angle of 90 means +y in TB, -x in Godot

	print("_calc_add()")
	_gen_aabb()
	
	#if !(props.get('spawnflags', 0) & 0b100) :
		#for n in get_tree().get_nodes_in_group(&'doors') :
			##if n.calc_ : continue
			#n._calc_add()
			#if n._no_linking() :
				#continue
				#
			#if (
				#aabb.size.x >= 0 and aabb.size.y >= 0 and
				#n.aabb.size.x >= 0 and n.aabb.size.y >= 0
			#) :
				#if aabb.grow(0.01).intersects(n.aabb) :
					#_add_link(n)
					#n._add_link(self)

	var s:float = 32.0
	
	if angle == -1:
		add = Vector3(0.0, aabb.size.y - lip, 0.0)
	elif angle == -2:
		add = Vector3(0.0, -aabb.size.y + lip, 0.0)
	else:
		var rot := (angle / 180.0) * PI
		print("rot is ", rot)
		print("aabb is ", aabb)
		var dir := -(Vector3(
			aabb.size.x, 0.0, aabb.size.z
		)) + Vector3(lip, 0.0, lip)
		print("dir = %s" % [dir])
		add = Vector3.BACK.rotated(Vector3.UP, rot) * dir
		add_reveal = Vector3.LEFT.rotated(Vector3.UP, -rot) * -(Vector3(
			aabb.size.x, 0.0, aabb.size.z
		))
	
	#DebugDraw3D.draw_box(position, Quaternion.IDENTITY, Vector3.ONE * 2, Color.CORNFLOWER_BLUE)

	print("add = %s" % [add])
	dura = add.length() / (speed / s)
	print("dura = %s / (%s / %s) = %s" % [add.length(), speed, s, dura])

func _move_pre(_tween:Tween) -> Vector3:
	return position
	
func _move_return() -> void:
	_move()

func _move() -> void:
	tween = create_tween()
	var basepos := _move_pre(tween)
	
	print("_move()")
	print("add: ", add)
	print("basepos: ", basepos)
	print("dura: ", dura)
	
	if open:
		tween.tween_property(self, ^'position',
			basepos - add, dura
		).finished.connect(_motion_f.bind(true))
		#tween.tween_property(self, ^'position', startPosition, dura).finished.connect(_motion_f.bind(true))
		#state = DoorState.CLOSED
	else:
		tween.tween_property(self, ^'position',
			basepos + add, dura
		).finished.connect(_motion_f.bind(true))
		#tween.tween_property(self, ^'position', endPosition, dura)
		#state = DoorState.OPEN
	
	open = !open

	#_play_snd(_get_sound_index_loop())
	#player_end = false
	
	if wait != -1:
		tween.tween_interval(wait)
		tween.finished.connect(_move_return)


func _motion_f(destroy_tween:bool = false) -> void:
	#player_end = true
	if destroy_tween:
		tween.kill()
		tween = null
