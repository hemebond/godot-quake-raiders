extends Node3D
class_name trigger_relay


@export var targetname:String = ""
@export var target:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("T_" + targetname, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func use(args:Array) -> void:
	var caller:Node = args[0]
	print("trigger_relay ", self, " use method called by ", caller)
	
	get_tree().call_group("T_" + target, "use", [self])
