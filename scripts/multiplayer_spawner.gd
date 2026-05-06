extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(remove_player)


func spawn_player(id: int) -> void:
	if not multiplayer.is_server(): return
	
	var player: Node = network_player.instantiate()
	player.name = str(id)
	#player.position = Vector3(-105, -12, -170)
	
	# find an info_player_start
	var spawn_point:Node3D = find_child("InfoPlayerStart")
	player.position = spawn_point.position
	player.rotation = spawn_point.rotation
	
	get_node(spawn_path).call_deferred("add_child", player)


func remove_player(id: int) -> void:
	if not $Game.has_node(str(id)):
		return
	
	$Game.get_node(str(id)).queue_free()
