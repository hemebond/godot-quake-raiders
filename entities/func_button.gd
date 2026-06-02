@tool
extends StaticBody3D

@export var target : String
@export var angle : Vector3

var unit_size: float = 32.0
var aabb: AABB

func _ready() -> void:
	print("func_button._ready()")
	if (Engine.is_editor_hint()):
		return  # don't do this stuff in editor (tool mode)
		
	print("Button ready")
	
func _process(_delta: float) -> void:
	pass

func post_import(_root_node: Node) -> void:
	print("func_button post_import")
	print(_root_node)
	print(self)
	
	# creating func_button area
	var area := Area3D.new()
	add_child(area)
	area.owner = _root_node  # have to set the owner to the scene root for it to show up in the Scene Tree
	#set_collision_layer_mask(area, ["func_button-areas"], ["func_button-characters"])
	
	# Do not make the trigger a part of the world or the entities
	area.set_collision_layer_value(1, false)
	
	# Watch for collisions only from other entities
	area.set_collision_mask_value(1, false)  # do not detect collisions from the world
	area.set_collision_mask_value(2, true)  # watch for collisions from entities
	
	#root_node.set("_area", root_node.get_path_to(area))
	
	# connecting func_button area signals
	area.body_entered.connect(Callable(self, "_on_body_entered"), CONNECT_PERSIST)
	area.monitorable = true

	aabb = $Mesh.get_aabb()
	
	# creating func_button area collision shape
	#var collision_shape := CollisionShape3D.new()
	#collision_shape.position = aabb.get_center()
	#collision_shape.shape = BoxShape3D.new()
	#var grow_units: float = 16.0 / unit_size
	#collision_shape.shape.size = aabb.grow(grow_units).size
	#collision_shape.shape.size += Vector3(0.1, 0.1, 0.1)
	
	#area.add_child(collision_shape)
	
	# Copy all the collision shapes from the entity to
	# the trigger (area3D) and expand them a little
	for child in get_children():
		if child.is_class("CollisionShape3D"):
			var dupe : CollisionShape3D = child.duplicate()
			dupe.shape = dupe.shape.duplicate()  # have to duplicate the shape to make it unique before we resize it
			dupe.shape.size += Vector3(0.1, 0.1, 0.1)
			area.add_child(dupe)
			dupe.owner = _root_node
	
	
	
func touch(other:Node) -> void:
	print("func_button", self, " touched by ", other)


func _on_body_entered(body: Node3D) -> void:
	print("_on_body_entered()")
	touch(body)
	
	for n in get_tree().get_nodes_in_group("T_elevator_48_door_top"):
		print(n)
	
	print("Calling group T_", target)
	get_tree().call_group("T_" + target, "use", [self])
	
