extends Node3D
class_name trigger_deactivate


@export var targetname:String =""
@export var target:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if targetname:
		add_to_group("T_" + targetname, true)


func use(args:Array) -> void:
	var caller:Node = args[0]
	print("trigger_deactivate ", self, " use() called by ", caller)

	if target:
		get_tree().call_group("T_" + target, "use", [self])
