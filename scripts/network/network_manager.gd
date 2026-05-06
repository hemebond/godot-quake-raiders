extends Node

const PORT: int = 42069

var is_hosting_game = false

const GAME_SCENE = "uid://dgcbevg7wm4wv"  # game.tscn
const MAIN_MENU_SCENE = "uid://bsn8o457q00p0"  # main_menu.tscn


func create_server() -> void:
	is_hosting_game = true
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)  # MAX_CLIENTS defaults to 32
	multiplayer.multiplayer_peer = peer
	print("server created")



func create_client(host: String = "localhost", port: int = PORT) -> void:
	is_hosting_game = false
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(host, port)
	multiplayer.multiplayer_peer = peer
	print("client peer created")
	_setup_client_connection_signals()



func send_test_message() -> void:
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



func _setup_client_connection_signals() -> void:
	if not multiplayer.server_disconnected.is_connected(_server_disconnected):
		multiplayer.server_disconnected.connect(_server_disconnected)
		print("connected disconnect signal")


func _server_disconnected() -> void:
	print("Server disconnected")
	terminate_connection_load_main_menu()
	

func load_game_scene() -> void:
	print("Loading game scene")
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))



func terminate_connection_load_main_menu() -> void:
	print("Terminate connection, load main menu")
	_load_main_menu()
	_terminate_connection()
	_disconnect_client_connection_signals()



func _load_main_menu() -> void:
	get_tree().call_deferred(&"change_scene_to_packed", preload(MAIN_MENU_SCENE))


func _terminate_connection() -> void:
	print("Terminate connection")
	multiplayer.multiplayer_peer = null


func _disconnect_client_connection_signals() -> void:
	if multiplayer.server_disconnected.has_connections():
		multiplayer.server_disconnected.disconnect(_server_disconnected)
		print("connected disconnect signal")
