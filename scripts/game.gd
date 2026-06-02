extends Node3D



@export var player_scene:PackedScene
@export var player_container:Node3D

const DEFAULT_PORT:int = 7777
const MAX_PLAYERS:int = 8

@onready var main_menu: Control = $main_menu

const GAME_SCENE = "uid://dgcbevg7wm4wv"  # game.tscn
const MAIN_MENU_SCENE = "uid://bsn8o457q00p0"  # main_menu.tscn


var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func _ready() -> void:
	main_menu.send_test_msg.connect(_send_test_msg)
	main_menu.start_game.connect(start_game)
	main_menu.join_game.connect(join_game)
	%world.hide()



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event.is_action_pressed("toggle_map"):
		# FIXME: This does not work in multiplayer
		print("peer: ", peer.get_unique_id())
		print("multiplayer: ", multiplayer.get_unique_id())
		var player = $players.get_node(str(peer.get_unique_id()))
		print(player)
		if $map_viewer.visible:
			#%world.show()
			$map_viewer.hide()
			$map_viewer/ship_editor/camera_gimbal.set_process_input(false)
			player.camera.make_current()
			player.set_process_input(true)
		else:
			$map_viewer.show()
			$map_viewer/ship_editor/camera_gimbal.set_process_input(true)
			$map_viewer/ship_editor/camera_gimbal/inner_gimbal/camera.make_current()
			#%world.hide()
			# FIXME: this does not work in multiplayer
			player.set_process_input(false)
			



func start_game(port:int = DEFAULT_PORT) -> Error:
	print("Starting host!")
	
	%world.show()
	main_menu.hide()

	#var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error:Error = peer.create_server(port, MAX_PLAYERS)

	if error != OK:
		push_error("Failed to create server: %s" % error_string(error))
		return error

	multiplayer.multiplayer_peer = peer
	
	# Only connect signals now that we have a server, otherwise will cause problems
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	#multiplayer.connected_to_server.connect(_on_connected_to_server)
	#multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Add the host to the game
	_on_peer_connected(1)

	return OK



func _on_peer_connected(id:int) -> void:
	print("Player %s joined the game" % id)
	
	# Setup player
	var player:QmapbspQuakePlayer = player_scene.instantiate()
	player.name = str(id)
	
	# Move the new player to the spawn point
	# Assign the position to transform.origin because objects not yet in the tree have no global_position
	#var info_player_start : Node3D = get_tree().get_current_scene().get_node("world/test/info_player_start")
	#player_to_add.transform.origin = info_player_start.global_position
	
	# Spawn player
	player_container.call_deferred("add_child", player)



func _on_peer_disconnected(id:int) -> void:
	print("Player %s left the game" % id)

	if not player_container.has_node(str(id)):
		return
	
	player_container.get_node(str(id)).queue_free()



func join_game() -> void:
	print("Joining game")
	
	%world.show()
	main_menu.hide()
	
	var _error:Error = peer.create_client("localhost", DEFAULT_PORT)
	
	multiplayer.multiplayer_peer = peer






func _send_test_msg() -> void:
	_send_test_message.rpc("Hello there")

@rpc("any_peer", "call_remote")
func _send_test_message(message: String) -> void:
	print(
		"Message [%s] received on peer [%s] from peer [%s]" % [
			message,
			multiplayer.get_unique_id(),
			multiplayer.get_remote_sender_id()
		]
	)
