extends Node3D

var LERP_SPEED:float = 48.0

func _ready() -> void:
	self.global_position = $"..".global_position

func _process(delta:float) -> void:
	var a:Vector3 = self.global_position
	var b:Vector3 = $"..".global_position
	var t:float = delta * LERP_SPEED
	
	self.global_position = b
	var smooth_y:float = lerp(a.y, b.y, t)
	self.global_position.y = smooth_y
