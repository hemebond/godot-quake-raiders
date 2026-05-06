@tool
extends StaticBody3D

@export var target : String
@export var angle : Vector3

func _ready() -> void:
	if (Engine.is_editor_hint()):
		return  # don't do this stuff in editor (tool mode)
		
	print("Button ready")
	
func _process(_delta: float) -> void:
	pass

func post_import(_root_node: Node) -> void:
	print("func_button post_import")
	
