extends Area3D

func _ready() -> void:
	var fog_volume = find_children("", "FogVolume")[0]
	
	for child in find_children("", "CollisionShape3D"):
		var shape = child.shape
			
		fog_volume.size = shape.size
		fog_volume.position = child.position
