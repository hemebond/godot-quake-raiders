@tool
extends Node3D

@export var targetname : String
@export var spawnflags : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func post_import(root_node: Node):
	if targetname != "":
		if spawnflags & 2:
			pass
