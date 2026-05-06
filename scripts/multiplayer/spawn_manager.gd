class_name SpawnManager
extends Node


var player_scene: PackedScene


func _ready() -> void:
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

	for id in multiplayer.get_peers():
		_add_player_to_game(id)
	
	_add_player_to_game(1)  # add host to game


func _peer_connected(id: int) -> void:
	print("Peer connected: %s" % id)
	_add_player_to_game(id)
	
	
func _peer_disconnected(id: int) -> void:
	print("Peer disconnected: %s" % id)


func _add_player_to_game(id: int) -> void:
	var player_to_add = player_scene.instantiate()
	player_to_add.name = str(id)
	#player_to_add.set_multiplayer_authority(1)
	player_to_add.player = id
	player_to_add.position = Vector3(-105, -12, -170)

	# find an info_player_start
	var spawn_point:Node3D = get_tree().current_scene.get_node("world").find_child("InfoPlayerStart")
	player_to_add.position = spawn_point.position
	player_to_add.rotation = spawn_point.rotation

	get_tree().current_scene.get_node("players").add_child(player_to_add, true)
	print("Adding player %s with authority 1" % [
		id
	])
