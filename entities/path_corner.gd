@tool
extends Node3D

@export var targetname:StringName
@export var angle:Vector3
@export var target_on_activate:StringName
@export var wait:float
@export var target:StringName
@export var speed:float



func _enter_tree() -> void:
	if targetname:
		add_to_group('T_' + targetname, true)
