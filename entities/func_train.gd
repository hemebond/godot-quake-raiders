@tool
extends StaticBody3D



@export var target:StringName
@export var targetname:StringName
@export var speed:float

@export var aabb:AABB

var tween:Tween
var current_target:Node3D
var next_target:Node3D


func _enter_tree() -> void:
	if targetname:
		add_to_group('T_' + targetname, true)



func _ready() -> void:
	print("[%s]_onready()" % name)
	current_target = get_tree().get_first_node_in_group("T_" + target)

	# Place the train onto the first point
	move_to_point(current_target.position)

	next_target = get_tree().get_first_node_in_group("T_" + current_target.target)


func use(other:Node) -> void:
	print("[%s]use()" % name)
	trigger(other)

func trigger(other:Node) -> void:
	print("[%s]trigger()" % name)
	activate()


func activate() -> void:
	print("[%s]activate()" % name)
	tween = create_tween()

	var target_position = next_target.position - Vector3(aabb.end.x, aabb.position.y, aabb.end.z)

	tween.tween_property(self, ^'position', target_position, 4.0).finished.connect(_motion_f)

	if current_target.wait != -1 :
		tween.tween_interval(current_target.wait)


func _motion_f() -> void:
	print("Tween finished")

	current_target = next_target
	next_target = get_tree().get_first_node_in_group("T_" + current_target.target)


func move_to_point(point:Vector3) -> void:
	# -x, -y, -z corner in TrenchBroom becomes +x, -y, +z corner in Godot
	position = point - Vector3(aabb.end.x, aabb.position.y, aabb.end.z)




func post_import(root_node: Node) -> void:
	_gen_aabb()

	# Adjust everything so the origin is in the center of the entity
	var offset:Vector3 = aabb.get_center()
	for c in get_children():
		c.position = c.position - offset
	aabb.position -= offset
	position += offset



func _gen_aabb() -> void:
	var mins:Vector3 = Vector3.INF
	var maxs:Vector3 = -Vector3.INF
	for child in get_children():
		if (child is CollisionShape3D):
			var shape:Shape3D = child.shape
			if (shape is ConvexPolygonShape3D):
				for point in shape.points:
					point = child.transform * point
					mins = mins.min(point)
					maxs = maxs.max(point)
			elif (shape is BoxShape3D):
				# Since these can be transformed, the negative shape might not actually be the min.
				var a:Vector3 = child.transform * (-shape.size * 0.5)
				var b:Vector3 = child.transform * (shape.size * 0.5)
				mins = mins.min(a)
				mins = mins.min(b)
				maxs = maxs.max(a)
				maxs = maxs.max(b)
			else:
				printerr("Unhandled shape in ", self, ": ", shape)

	aabb = AABB(mins, maxs - mins)
