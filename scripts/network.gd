extends Node



const PORT: int = 42069


var is_hosting_game = false


func create_server() -> void:
	is_hosting_game = true
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)  # MAX_CLIENTS defaults to 32
	multiplayer.multiplayer_peer = peer
	print("server created")



func create_client(host: String = "localhost", port : int = PORT) -> void:
	is_hosting_game = false
	_setup_client_connection_signals()
	
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(host, port)
	multiplayer.multiplayer_peer = peer
	print("client peer created")
	



func _setup_client_connection_signals() -> void:
	if not multiplayer.server_disconnected.is_connected(_server_disconnected):
		multiplayer.server_disconnected.connect(_server_disconnected)
		print("connected disconnect signal")

func _server_disconnected() -> void:
	print("Server disconnected")
	multiplayer.multiplayer_peer = null
	


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
