@tool
extends Node3D

class_name info_structure



var override_material:Material = load("res://materials/map_blocks.tres")


func post_import(_root_node: Node) -> void:
	for c in get_children():
		print(c.get_class())
		if c.is_class("CollisionShape3D"):
			remove_child(c)
			c.queue_free()
		elif c.name == "Mesh":
			var m:MeshInstance3D = c
			m.set_layer_mask_value(1, false)
			m.set_layer_mask_value(2, true)
			m.set_surface_override_material(0, override_material)
