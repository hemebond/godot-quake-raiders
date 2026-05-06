extends Node

const PORT = 8910
const MAX_CLIENTS = 4

func _ready():
	start_server()

func start_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CLIENTS)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Server started on port ", PORT)
		
		# Spawn server player
		add_player(1)  # Server is always ID 1
	else:
		print("Failed to start server: ", error)

func add_player(id: int):
	var player = preload("").instantiate()
	player.name = "Player" + str(id)
	player.set_multiplayer_authority(id)
	add_child(player)
