@tool
extends StaticBody3D
class_name func_door

const SF_DONT_LINK = 2

@export var targetname : String
@export var spawnflags : int


@onready var startPosition:Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if targetname:
		print("Adding ", self, "to group", "T_" + targetname)
		add_to_group('T_' + targetname, true)
	
	startPosition = position

func post_import(_root_node: Node) -> void:
	print("func_door.post_import()")
	
	add_to_group(&"doors", true)
	if targetname or !(spawnflags & SF_DONT_LINK):
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
	var caller = args[0]
	print("This is func_door.use() called by ", caller)
